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
	#--check row
	var tiles_to_clear : Array[Vector2i]
	var bonus_tiles : Array[Vector2i]
	for column : int in range(GRID_TOP_LIMIT.y, GRID_BOTTOM_LIMIT.y + 1):
		var temp_tiles_to_clear : Array[Vector2i]
		for row : int in range(GRID_TOP_LIMIT.x, GRID_BOTTOM_LIMIT.x + 1):
			if tilemap.get_cell_source_id(Vector2i(row, column)) == -1: temp_tiles_to_clear.clear(); break
			temp_tiles_to_clear.append(Vector2i(row, column))
		tiles_to_clear.append_array(temp_tiles_to_clear)
	#--check column
	var add_bonus : int = 0
	for row : int in range(GRID_TOP_LIMIT.x, GRID_BOTTOM_LIMIT.x + 1):
		var temp_tiles_to_clear : Array[Vector2i]
		var temp_add_bonus : int = 0
		var temp_bonus_tiles : Array[Vector2i]
		for column : int in range(GRID_TOP_LIMIT.y, GRID_BOTTOM_LIMIT.y + 1):
			if tilemap.get_cell_source_id(Vector2i(row, column)) == -1: temp_tiles_to_clear.clear(); temp_bonus_tiles.clear(); break
			if tiles_to_clear.has(Vector2i(row, column)): temp_add_bonus += 1; temp_bonus_tiles.append(Vector2i(row,column))
			temp_tiles_to_clear.append(Vector2i(row, column))
		add_bonus += temp_add_bonus
		tiles_to_clear.append_array(temp_tiles_to_clear)
		bonus_tiles.append_array(temp_bonus_tiles)
	#-1 means no tiles exist, now we all the tile coords that going to be cleared

	#we add sprites to add some animation secretly deleting the actual tile 
	for tile_pos : Vector2i in tiles_to_clear:
		if bonus_tiles.has(tile_pos): continue
		#await get_tree().create_timer(0.1).timeout
		var new_sprite := Sprite2D.new()
		new_sprite.texture = load("res://tile.jpg")
		new_sprite.position = tilemap.map_to_local(tile_pos)
		new_sprite.self_modulate = PUFF_COLORS[tilemap.get_cell_alternative_tile(tile_pos)] 
		add_child(new_sprite)
		tilemap.set_cell(tile_pos)
		var tween = create_tween()
		tween.tween_property(new_sprite, "scale", Vector2.ONE * 0.8, 0.1)
		tween.tween_property(new_sprite, "scale", Vector2.ONE, 0.1)
		tween.tween_property(new_sprite, "scale", Vector2.ZERO, 0.1)
		await tween.finished
		new_sprite.queue_free()

	#same as above but we wanted to clear the overlapping tiles separately
	await get_tree().create_timer(0.08).timeout
	for tile_pos : Vector2i in bonus_tiles:
		#await get_tree().create_timer(0.05).timeout
		var new_sprite := Sprite2D.new()
		new_sprite.texture = load("res://tile.jpg")
		new_sprite.position = tilemap.map_to_local(tile_pos)
		new_sprite.self_modulate = PUFF_COLORS[tilemap.get_cell_alternative_tile(tile_pos)] 
		add_child(new_sprite)
		tilemap.set_cell(tile_pos)
		var tween = create_tween()
		tween.tween_property(new_sprite, "scale", Vector2.ONE * 0.8, 0.05)
		tween.tween_property(new_sprite, "scale", Vector2.ONE, 0.04)
		tween.tween_property(new_sprite, "scale", Vector2.ZERO, 0.02)
		await tween.finished
		new_sprite.queue_free()
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

