extends Panel

@export var tile_map_builder 	: GameTileMapBuilder
@export var width 				: SpinBox
@export var height 				: SpinBox
@export var load_game 			: Button
@export var save_game 			: Button
@export var choose_mode 		: OptionButton
@export var play_game 			: Button
@export var save_file_manager 	: SaveFileManager

func _ready():
	width.value = tile_map_builder.width
	height.value = tile_map_builder.height
	width.value_changed.connect(size_changed)
	height.value_changed.connect(size_changed)
	load_game.button_down.connect(load_game_clicked)
	save_game.button_down.connect(save_game_clicked)
	play_game.button_down.connect(play_game_clicked)
	choose_mode.item_selected.connect(choose_mode_changed)
	choose_mode.add_item("PLACE",0)
	choose_mode.add_item("MOVE",1)
	choose_mode.add_item("DELETE",2)

func play_game_clicked():
	get_tree().change_scene_to_file("res://Scenes/play_mode.tscn")

func choose_mode_changed(new_mode : int):
	tile_map_builder.building_index = -1
	tile_map_builder.move_building = null
	if new_mode == 0:
		tile_map_builder.current_mode = GameTileMapBuilder.BUILDER_MODE.PLACE
	elif new_mode == 1:
		tile_map_builder.current_mode = GameTileMapBuilder.BUILDER_MODE.MOVE
	elif new_mode == 2:
		tile_map_builder.current_mode = GameTileMapBuilder.BUILDER_MODE.DELETE
		
func _process(delta: float) -> void:
	choose_mode.selected = tile_map_builder.current_mode

func load_game_clicked():
	save_file_manager.RequestOpenGameLevelMapFile()
func save_game_clicked():
	save_file_manager.RequestSaveGameLevelMapFile()

func size_changed(new_value):
	tile_map_builder.set_new_size(width.value,height.value)
