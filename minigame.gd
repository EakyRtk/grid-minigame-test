extends Node2D

class PatternTexture:
	var h_flip: bool 
	var v_flip : bool
	var textur 
	func _init(ptextur, ph_flip = false, pv_flip = false) -> void:
		pass
		h_flip = ph_flip
		v_flip = pv_flip
		textur = ptextur

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

#------------------------------------------------------
#7 layers of the Hell of Definitions !!!
enum COLORS {WHITE, CYAN, RED, GREEN}

enum PATTERNS {
	SQUARE,
	PAR_TOP_LEFT, PAR_TOP_RIGHT, PAR_BOTTOM_LEFT, PAR_BOTTOM_RIGHT,
	WALK_UPLEFT, WALK_UPRIGHT, WALK_DOWNLEFT, WALK_DOWNRIGHT,
	SIT_LEFT, SIT_RIGHT, REVERSE_SIT_LEFT, REVERSE_SIT_RIGHT,
	UPLINE, HORIZONTAL_LINE,
	T_UP, T_LEFT, T_RIGHT, T_DOWN,
	BULKY_DOWN, BULKY_UP, BULKY_RIGHT, BULKY_LEFT,
	LONG_LINE_UP, LONG_LINE_HORIZONTAL,
	CLOSE_UPLEFT, CLOSE_UPRIGHT, CLOSE_BOTLEFT, CLOSE_BOTRIGHT,
	U_UP, U_LEFT, U_RIGHT, U_DOWN,
	STICK_UP, STICK_RIGHT, STICK_LEFT, STICK_DOWN,
	BOW_BOTRIGHT, BOW_BOTLEFT, BOW_UPRIGHT, BOW_UPLEFT,
	PLUS

}

var images : Dictionary = {
	PATTERNS.SQUARE: preload("res://pattern-images/square.png"),

	PATTERNS.PAR_TOP_LEFT: preload("res://pattern-images/par_top_left.png"),

	PATTERNS.WALK_UPLEFT: preload("res://pattern-images/walk_upleft.png"),
	PATTERNS.WALK_DOWNLEFT: preload("res://pattern-images/walk_botleft.png"),

	PATTERNS.SIT_LEFT: preload("res://pattern-images/sit_left.png"),

	PATTERNS.UPLINE: preload("res://pattern-images/upline.png"),
	PATTERNS.HORIZONTAL_LINE: preload("res://pattern-images/horizontal_line.png"),

	PATTERNS.T_UP: preload("res://pattern-images/t_up.png"),
	PATTERNS.T_RIGHT: preload("res://pattern-images/t_right.png"),

	PATTERNS.BULKY_DOWN: preload("res://pattern-images/bulky_down.png"),
	PATTERNS.BULKY_RIGHT: preload("res://pattern-images/bulky_right.png"),

	PATTERNS.LONG_LINE_UP: preload("res://pattern-images/long_line_up.png"),
	PATTERNS.LONG_LINE_HORIZONTAL: preload("res://pattern-images/long_line_horizontal.png"),

	PATTERNS.CLOSE_UPLEFT: preload("res://pattern-images/close_upleft.png"),

	PATTERNS.U_UP: preload("res://pattern-images/u_up.png"),
	PATTERNS.U_RIGHT: preload("res://pattern-images/u_right.png"),

	PATTERNS.STICK_UP: preload("res://pattern-images/stick_up.png"),
	PATTERNS.STICK_RIGHT: preload("res://pattern-images/stick_right.png"),

	PATTERNS.BOW_BOTRIGHT: preload("res://pattern-images/bow_botright.png"),

	PATTERNS.PLUS: preload("res://pattern-images/plus.png")


}
var pattern_images : Dictionary = {
	PATTERNS.SQUARE: PatternTexture.new(images[PATTERNS.SQUARE]),
	
	PATTERNS.PAR_TOP_LEFT: PatternTexture.new(images[PATTERNS.PAR_TOP_LEFT]),
	PATTERNS.PAR_TOP_RIGHT: PatternTexture.new(images[PATTERNS.PAR_TOP_LEFT], true),
	PATTERNS.PAR_BOTTOM_LEFT: PatternTexture.new(images[PATTERNS.PAR_TOP_LEFT], false, true),  
	PATTERNS.PAR_BOTTOM_RIGHT: PatternTexture.new(images[PATTERNS.PAR_TOP_LEFT], true, true),
	
	PATTERNS.WALK_UPLEFT: PatternTexture.new(images[PATTERNS.WALK_UPLEFT]), 
	PATTERNS.WALK_UPRIGHT: PatternTexture.new(images[PATTERNS.WALK_UPLEFT], false, true), 
	PATTERNS.WALK_DOWNLEFT: PatternTexture.new(images[PATTERNS.WALK_DOWNLEFT]), 
	PATTERNS.WALK_DOWNRIGHT: PatternTexture.new(images[PATTERNS.WALK_DOWNLEFT], true),
	
	PATTERNS.SIT_LEFT: PatternTexture.new(images[PATTERNS.SIT_LEFT]), 
	PATTERNS.SIT_RIGHT: PatternTexture.new(images[PATTERNS.SIT_LEFT], true), 
	PATTERNS.REVERSE_SIT_LEFT: PatternTexture.new(images[PATTERNS.SIT_LEFT], false, true), 
	PATTERNS.REVERSE_SIT_RIGHT: PatternTexture.new(images[PATTERNS.SIT_LEFT], true, true),
	
	PATTERNS.UPLINE: PatternTexture.new(images[PATTERNS.UPLINE]), 
	PATTERNS.HORIZONTAL_LINE: PatternTexture.new(images[PATTERNS.HORIZONTAL_LINE]),
	
	PATTERNS.T_UP: PatternTexture.new(images[PATTERNS.T_UP]),
	PATTERNS.T_LEFT: PatternTexture.new(images[PATTERNS.T_RIGHT]), 
	PATTERNS.T_RIGHT: PatternTexture.new(images[PATTERNS.T_RIGHT], true), 
	PATTERNS.T_DOWN: PatternTexture.new(images[PATTERNS.T_UP], false, true),
	
	PATTERNS.BULKY_DOWN: PatternTexture.new(images[PATTERNS.BULKY_DOWN]), 
	PATTERNS.BULKY_UP: PatternTexture.new(images[PATTERNS.BULKY_DOWN], true, true), 
	PATTERNS.BULKY_RIGHT: PatternTexture.new(images[PATTERNS.BULKY_RIGHT]), 
	PATTERNS.BULKY_LEFT: PatternTexture.new(images[PATTERNS.BULKY_RIGHT], true),
	
	PATTERNS.LONG_LINE_UP: PatternTexture.new(images[PATTERNS.LONG_LINE_UP]), 
	PATTERNS.LONG_LINE_HORIZONTAL: PatternTexture.new(images[PATTERNS.LONG_LINE_HORIZONTAL]),
	
	PATTERNS.CLOSE_UPLEFT: PatternTexture.new(images[PATTERNS.CLOSE_UPLEFT]), 
	PATTERNS.CLOSE_UPRIGHT: PatternTexture.new(images[PATTERNS.CLOSE_UPLEFT], true), 
	PATTERNS.CLOSE_BOTLEFT: PatternTexture.new(images[PATTERNS.CLOSE_UPLEFT], false, true), 
	PATTERNS.CLOSE_BOTRIGHT: PatternTexture.new(images[PATTERNS.CLOSE_UPLEFT], true, true),
	
	PATTERNS.U_UP: PatternTexture.new(images[PATTERNS.U_UP]), 
	PATTERNS.U_LEFT: PatternTexture.new(images[PATTERNS.U_RIGHT], true), 
	PATTERNS.U_RIGHT: PatternTexture.new(images[PATTERNS.U_RIGHT]), 
	PATTERNS.U_DOWN: PatternTexture.new(images[PATTERNS.U_UP], false, true),
	
	PATTERNS.STICK_UP: PatternTexture.new(images[PATTERNS.STICK_UP]), 
	PATTERNS.STICK_RIGHT: PatternTexture.new(images[PATTERNS.STICK_RIGHT]), 
	PATTERNS.STICK_LEFT: PatternTexture.new(images[PATTERNS.STICK_RIGHT], true, true), 
	PATTERNS.STICK_DOWN: PatternTexture.new(images[PATTERNS.STICK_UP], true, true),
	
	PATTERNS.BOW_BOTRIGHT: PatternTexture.new(images[PATTERNS.BOW_BOTRIGHT]), 
	PATTERNS.BOW_BOTLEFT: PatternTexture.new(images[PATTERNS.BOW_BOTRIGHT], true), 
	PATTERNS.BOW_UPRIGHT: PatternTexture.new(images[PATTERNS.BOW_BOTRIGHT], false, true), 
	PATTERNS.BOW_UPLEFT: PatternTexture.new(images[PATTERNS.BOW_BOTRIGHT], true, true),
	
	PATTERNS.PLUS: PatternTexture.new(images[PATTERNS.PLUS]) 
	
}
#-------------------------------------------------------


##What pattern is currently selected
var holding_pattern 
var current_holding_button : TextureButton

@onready var buttons_container : VBoxContainer = %PatternButtonsContainer
@onready var playing_area_rect : NinePatchRect = $PlayingAreaRect
@onready var tilemap : TileMapLayer = $TileMapLayer
var currently_clearing : bool = false
#----visual side
@onready var holding_sprite : Sprite2D = $HoldingTexture
@onready var pattern_visual : TileMapLayer = %TileMapVisual
var previous_mouse_pos : Vector2i
#----

#-----------------*--------------------*-----------------------*
#   SCORING              STUFF               O YEAH

@onready var score_box : VBoxContainer = %ScoresBox
@onready var score_label : Label = %TotalScoreLabel

var total_score : int = 0

@export_category("Scores")
##Score you'll get from each tile of the pattern
@export var score_block_place : int = 10
##Score that you'll get from a row or a column clear
@export var score_line_clear : int = 100
##Score for getting a row and column clear at the same time
@export var score_row_and_column : int = 200
##Score multiplier for clearing multiple rows OR columns at the same time
@export var score_m_row_or_column : int = 300
##Score multiplier for clearing multiple rows AND columns at the same time
@export var score_m_row_and_column : int = 600
#-----------------*--------------------*-----------------------*

#NOTE: Repo has some little explanations on the pattern and coloring matter

#--DESIGN----------
#for this design we have the rules as going:
#Can't place a pattern if:
#	Pattern leaking from the area
#	Already a tile is placed
#	Trying to place outside of the limits
#	NOTE: (Not added yet) Can't place while some rows and/or columns getting cleared
#------------------

#-----------------------------------------------------------------------------------
#region Gameplay

#We get local tile coords from the pattern starting from [0,0] but we need its relative position to the map so we add the position we clicked as tilemap coords
#its like taking the click coords as a parent location. Also we have to check if these coordinats overlap with any tiles that already placed with get_used_cells
func add_pattern_at_pos(pos: Vector2i = Vector2i.ZERO, color: COLORS = COLORS.WHITE, pattern: PATTERNS = holding_pattern, target_tilelayer : TileMapLayer = tilemap)->void:
	var new_pattern : TileMapPattern = tilemap.tile_set.get_pattern(pattern)
	for tile : Vector2i in new_pattern.get_used_cells():
		if test_limits(tile + pos) or target_tilelayer.get_used_cells().has(tile + pos): return
		new_pattern.set_cell(tile, 0, Vector2i.ZERO, color)
	target_tilelayer.set_pattern(pos, new_pattern)
	holding_sprite.hide()
	if target_tilelayer == pattern_visual: return
	add_score("+%s", new_pattern.get_used_cells().size() * score_block_place)
	current_holding_button.queue_free()
	current_holding_button = null
	holding_sprite.texture = null
	clear_piece()

#we want to store the rows and columns that are going to be cleared but we must be careful to not include rows and/or columns that arent fill the raw/column
#also shared tiles with the column and row clearing has to give extra points
func clear_piece()->void:
	currently_clearing = true

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

	var clear_row_and_columns : Callable = func(start_limit: int, finish_limit: int, clear_arr: Array[int], is_row : bool = true)->int:
		var clear_amount : int = 0
		for anchor_pos : int in range(start_limit, finish_limit):
			if clear_arr == []: break
			var will_await : bool = true
			for walk_pos : int in clear_arr:
				var pos : Vector2i
				if is_row: pos = Vector2i(anchor_pos, walk_pos)
				else: pos = Vector2i(walk_pos, anchor_pos) 
				if bonus_tiles.has(pos): will_await = false; clear_amount += 1; continue
				will_await = true
				var color_val : Color = PUFF_COLORS[tilemap.get_cell_alternative_tile(pos)]
				tilemap.set_cell(pos)
				clear_animation.call(pos, color_val, anim_time)
				clear_amount += 1
			if will_await: await get_tree().create_timer(anim_time).timeout
		return clear_amount

	var score_row_amount : int = 0
	var score_column_amount : int = 0
	score_row_amount +=	await clear_row_and_columns.call(GRID_TOP_LIMIT.x, GRID_BOTTOM_LIMIT.x + 1, rows)
	score_column_amount += await clear_row_and_columns.call(GRID_TOP_LIMIT.y, GRID_BOTTOM_LIMIT.y + 1, columns, false)
	print("row amount: %s" %score_row_amount)
	print("column amount:%s" % score_column_amount)
	#same as above but we wanted to clear the overlapping tiles separately
	await get_tree().create_timer(anim_time * 3).timeout
	for tile_pos : Vector2i in bonus_tiles:
		var color_val : Color = PUFF_COLORS[tilemap.get_cell_alternative_tile(tile_pos)]
		tilemap.set_cell(tile_pos)
		await clear_animation.call(tile_pos, color_val, 0.05)

	currently_clearing = false
	print("bonus :%s" % add_bonus)
	match add_bonus:
		0:
			score_row_amount /= (GRID_BOTTOM_LIMIT.x - GRID_TOP_LIMIT.x + 1)
			score_column_amount /= (GRID_BOTTOM_LIMIT.y - GRID_TOP_LIMIT.y + 1)
			print("2-row amount: %s" %score_row_amount)
			print("2-column amount:%s" % score_column_amount)
			if score_row_amount > 1: add_score("+%s Rows Clear!", score_row_amount * score_m_row_or_column)
			elif score_column_amount > 1: add_score("+%s Columns Clear!", score_column_amount  * score_m_row_or_column)
			elif score_column_amount == 0 and score_row_amount == 0: pass 
			else: add_score("+%s Line Clear", score_line_clear)
		1:
			add_score("+%s COMBO!!", score_row_and_column)
		_:
			add_score("+%s MULTI COMBO!", add_bonus * score_m_row_and_column)

#checks if the given corrds in between the playground we decided
func test_limits(pos_check: Vector2i)->bool:
	if pos_check.x > GRID_BOTTOM_LIMIT.x or pos_check.x < GRID_TOP_LIMIT.x or \
	pos_check.y < GRID_TOP_LIMIT.y or pos_check.y > GRID_BOTTOM_LIMIT.y: return true
	return false

#sets a tile to the mouse position
func set_tile_on_mouse_pos()->void:
	#print(tilemap.local_to_map(get_global_mouse_position()))
	var mouse_pos = get_global_mouse_position()
	var grid_mouse_pos = tilemap.local_to_map(mouse_pos)
	if test_limits(grid_mouse_pos): return
	tilemap.set_cell(tilemap.local_to_map(mouse_pos), 0, Vector2i.ZERO)


#sets the whole pattern on the mouse location
func set_pattern_on_mouse_pos()->void:
	var mouse_pos = get_global_mouse_position()
	var grid_mouse_pos = tilemap.local_to_map(mouse_pos)
	#print(tilemap.get_cell_source_id(grid_mouse_pos))
	if test_limits(grid_mouse_pos) or holding_pattern == null: return
	var rand_color: COLORS = randi_range(0, COLORS.size() - 1) as COLORS
	#var rand_pattern: PATTERNS = randi_range(0, PATTERNS.size() - 1) as PATTERNS
	add_pattern_at_pos(tilemap.local_to_map(get_global_mouse_position()), rand_color, holding_pattern)

#to show on grid
func set_visual_pattern_on_mouse_pos()->void:
	var mouse_pos = get_global_mouse_position()
	var grid_mouse_pos = pattern_visual.local_to_map(mouse_pos)
	if grid_mouse_pos == previous_mouse_pos: return
	pattern_visual.clear()
	previous_mouse_pos = grid_mouse_pos
	#print(pattern_visual.get_cell_source_id(grid_mouse_pos))
	if test_limits(grid_mouse_pos): return
	if holding_pattern == null: return
	else: holding_sprite.show()
	var rand_color: COLORS = randi_range(0, COLORS.size() - 1) as COLORS
	#var rand_pattern: PATTERNS = randi_range(0, PATTERNS.size() - 1) as PATTERNS
	add_pattern_at_pos(pattern_visual.local_to_map(get_global_mouse_position()), rand_color, holding_pattern, pattern_visual)



#endregion
#-----------------------------------------------------------------------------------

func add_score(score_text : String, n_score: int)->void:
	var _n_label := Label.new()
	_n_label.text = score_text % n_score
	var _lmbd : Callable = func(tmp_lbl): await get_tree().create_timer(2.5).timeout; tmp_lbl.queue_free()
	_n_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_n_label.tree_entered.connect(_lmbd.bind(_n_label))
	score_box.add_child(_n_label)
	total_score += n_score 
	score_label.text = "SCORE:\n%s" % total_score 

#-----------------------------------------------------------------------------------
#region ElementInteractions
func place_pattern_button()->void:
#	var test_patterns : Array[PATTERNS] = [PATTERNS.TINY_T, PATTERNS.TINY_T, PATTERNS.SQUARE]
	var test_patterns: Array[PATTERNS]
	test_patterns.append_array([PATTERNS.SQUARE, PATTERNS.SQUARE, PATTERNS.SQUARE, PATTERNS.SQUARE])
	for i : int in PATTERNS.size():
		test_patterns.append(i)


	for a_pattern: PATTERNS in test_patterns:
		var new_button := TextureButton.new()
		new_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		new_button.custom_minimum_size.y = 128
		
		var _ptr_textur : PatternTexture = pattern_images[a_pattern]
		new_button.texture_normal = _ptr_textur.textur
		new_button.flip_h = _ptr_textur.h_flip
		new_button.flip_v = _ptr_textur.v_flip

		new_button.set_meta("pattern", a_pattern)
		buttons_container.add_child(new_button)
		var press_func : Callable = func(pressed_button: TextureButton)->void:
			var bttn_pattern = pressed_button.get_meta("pattern") as PATTERNS
			holding_pattern = bttn_pattern
			current_holding_button = pressed_button
			var _btn_ptr_textur : PatternTexture = pattern_images[bttn_pattern]
			holding_sprite.texture = _btn_ptr_textur.textur
			holding_sprite.flip_h = _btn_ptr_textur.h_flip
			holding_sprite.flip_v = _btn_ptr_textur.v_flip 
		#------------------------------------------------------
		new_button.pressed.connect(press_func.bind(new_button))
		new_button.tree_exiting.connect(func(): holding_pattern = null)
		
#endregion
#-----------------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and not currently_clearing:
		set_pattern_on_mouse_pos()
		#set_tile_on_mouse_pos()

func _ready() -> void:
	playing_area_rect.mouse_entered.connect(func(): print("x"))
	playing_area_rect.mouse_exited.connect(func(): pass)
	place_pattern_button()

func _process(_delta: float) -> void:
	holding_sprite.position = get_global_mouse_position() + Vector2(-20, -20)
	set_visual_pattern_on_mouse_pos()
