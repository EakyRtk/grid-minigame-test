extends Node2D

enum COLORS {WHITE, CYAN, RED, GREEN}
enum PATTERNS {BULKY, LONG, SQUARE}

#playground limits as tilemap coords.
#top limit is the left top tile position
#bottom limit is the right bottom tile position
const GRID_TOP_LIMIT : Vector2i = Vector2i(4, 1)
const GRID_BOTTOM_LIMIT : Vector2i = Vector2i(9, 6)
 
const PUFF_COLORS : Dictionary = {
	-1: Color.WHITE,
	COLORS.WHITE: Color.WHITE,
	COLORS.CYAN: Color.CYAN,
	COLORS.RED: Color.RED,
	COLORS.GREEN: Color.GREEN
}

@onready var tilemap : TileMapLayer = $TileMapLayer

#NOTE: Repo has some little explanations on the pattern and coloring matter

#--DESIGN----------
#for this design we have the rules as going:
#Can't place a pattern if:
#	Pattern leaking from the area
#	Already a tile is placed
#	Trying to place outside of the limits
#	NOTE: (Not added yet) Can't place while some rows and/or columns getting cleared
#------------------

#We get local tile coords from the pattern starting from [0,0] but we need its relative position to the map so we add the position we clicked as tilemap coords
#its like taking the click coords as a parent location. Also we have to check if these coordinats overlap with any tiles that already placed with get_used_cells
func add_pattern_at_pos(pos: Vector2i = Vector2i.ZERO, color: COLORS = COLORS.WHITE, pattern: PATTERNS = PATTERNS.BULKY)->void:
	var new_pattern : TileMapPattern = tilemap.tile_set.get_pattern(pattern)
	for tile : Vector2i in new_pattern.get_used_cells():
		if test_limits(tile + pos) or tilemap.get_used_cells().has(tile + pos): return
		new_pattern.set_cell(tile, 0, Vector2i.ZERO, color)
	tilemap.set_pattern(pos, new_pattern)
	clear_piece()

#we want to store the rows and columns that are going to be cleared but we must be careful to not include rows and/or columns that arent fill the raw/column
#also shared tiles with the column and row clearing has to give extra points
func clear_piece()->void:
	var tiles_to_clear : Array[Vector2i]
	var bonus_tiles : Array[Vector2i]

	#UPDATE: In this model, tiles_to_clear only holds values to check bonus tiles
	#for the tile clearings, rows and columns hold the complete row and/or columns indexes (cuz y and/or x coords stay the same)
	var rows : Array[int]
	var columns : Array[int]
	#--check row
	for column_pos : int in range(GRID_TOP_LIMIT.y, GRID_BOTTOM_LIMIT.y + 1):
		var add_row_pos : int = -1
		var temp_tiles : Array[Vector2i]
		for row_pos : int in range(GRID_TOP_LIMIT.x, GRID_BOTTOM_LIMIT.x + 1):
			if tilemap.get_cell_source_id(Vector2i(row_pos, column_pos)) == -1: add_row_pos = -1; temp_tiles.clear(); break
			add_row_pos = column_pos
			temp_tiles.append(Vector2i(row_pos, column_pos))
		tiles_to_clear.append_array(temp_tiles)
		if add_row_pos != -1: rows.append(add_row_pos)

	#--check column
	var add_bonus : int = 0
	for row_pos : int in range(GRID_TOP_LIMIT.x, GRID_BOTTOM_LIMIT.x + 1):
		var temp_add_bonus : int = 0
		var temp_bonus_tiles : Array[Vector2i]
		var add_column_pos : int = -1 
		var temp_tiles : Array[Vector2i]
		for column_pos : int in range(GRID_TOP_LIMIT.y, GRID_BOTTOM_LIMIT.y + 1):
			if tilemap.get_cell_source_id(Vector2i(row_pos, column_pos)) == -1: add_column_pos = -1; temp_tiles.clear(); temp_bonus_tiles.clear(); break
			if tiles_to_clear.has(Vector2i(row_pos, column_pos)):
				temp_add_bonus += 1
				temp_bonus_tiles.append(Vector2i(row_pos, column_pos))
				add_column_pos = row_pos 
			add_column_pos = row_pos
			temp_tiles.append(Vector2i(row_pos, column_pos))
		add_bonus += temp_add_bonus
		tiles_to_clear.append_array(temp_tiles)
		if add_column_pos != -1: columns.append(add_column_pos)
		bonus_tiles.append_array(temp_bonus_tiles)
	#-1 means no tiles exist, now we all the tile coords that going to be cleared

	#we add sprites to add some animation secretly deleting the actual tile

	var clear_animation : Callable = func(pos: Vector2i, color_val: Color, time: float):
		var new_sprite := Sprite2D.new()
		new_sprite.texture = load("res://tile.jpg")
		new_sprite.position = tilemap.map_to_local(pos)
		new_sprite.self_modulate = color_val
		add_child(new_sprite)
		var tween = create_tween()
		tween.tween_property(new_sprite, "scale", Vector2.ONE * 0.8, time/3)
		tween.tween_property(new_sprite, "scale", Vector2.ONE, time/3)
		tween.tween_property(new_sprite, "scale", Vector2.ZERO, time/3)
		await tween.finished
		new_sprite.queue_free()

	var anim_time : float = 0.2 

	var clear_row_and_columns : Callable = func(start_limit: int, finish_limit: int, clear_arr: Array[int], is_row : bool = true):
		for anchor_pos : int in range(start_limit, finish_limit):
			if clear_arr == []: break
			var will_await : bool = true
			for walk_pos : int in clear_arr:
				var pos : Vector2i
				if is_row: pos = Vector2i(anchor_pos, walk_pos)
				else: pos = Vector2i(walk_pos, anchor_pos) 
				if bonus_tiles.has(pos): will_await = false; continue
				will_await = true
				var color_val : Color = PUFF_COLORS[tilemap.get_cell_alternative_tile(pos)]
				tilemap.set_cell(pos)
				clear_animation.call(pos, color_val, anim_time)
			if will_await: await get_tree().create_timer(anim_time).timeout

	clear_row_and_columns.call(GRID_TOP_LIMIT.x, GRID_BOTTOM_LIMIT.x + 1, rows)
	clear_row_and_columns.call(GRID_TOP_LIMIT.y, GRID_BOTTOM_LIMIT.y + 1, columns, false)
	#same as above but we wanted to clear the overlapping tiles separately
	await get_tree().create_timer(anim_time * 3).timeout
	for tile_pos : Vector2i in bonus_tiles:
		var color_val : Color = PUFF_COLORS[tilemap.get_cell_alternative_tile(tile_pos)]
		tilemap.set_cell(tile_pos)
		await clear_animation.call(tile_pos, color_val, 0.05)

	print(add_bonus)

#checks if the given corrds in between the playground we decided
func test_limits(pos_check: Vector2i)->bool:
	if pos_check.x > GRID_BOTTOM_LIMIT.x or pos_check.x < GRID_TOP_LIMIT.x or \
	pos_check.y < GRID_TOP_LIMIT.y or pos_check.y > GRID_BOTTOM_LIMIT.y: return true
	return false

#sets a tile to the mouse position
func set_tile_on_mouse_pos()->void:
	print(tilemap.local_to_map(get_global_mouse_position()))
	var mouse_pos = get_global_mouse_position()
	var grid_mouse_pos = tilemap.local_to_map(mouse_pos)
	if test_limits(grid_mouse_pos): return
	tilemap.set_cell(tilemap.local_to_map(mouse_pos), 0, Vector2i.ZERO)

#sets the whole pattern on the mouse location
func set_pattern_on_mouse_pos()->void:
	var mouse_pos = get_global_mouse_position()
	var grid_mouse_pos = tilemap.local_to_map(mouse_pos)
	print(tilemap.get_cell_source_id(grid_mouse_pos))
	if test_limits(grid_mouse_pos): return
	var rand_color: COLORS = randi_range(0, COLORS.size() - 1) as COLORS
	#var rand_pattern: PATTERNS = randi_range(0, PATTERNS.size() - 1) as PATTERNS
	add_pattern_at_pos(tilemap.local_to_map(get_global_mouse_position()), rand_color, PATTERNS.SQUARE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		set_pattern_on_mouse_pos()
		#set_tile_on_mouse_pos()
