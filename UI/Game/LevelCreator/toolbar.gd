extends Panel

@export var tile_map_builder 	: GameTileMapBuilder
@export var width 				: SpinBox
@export var height 				: SpinBox
@export var load_game 			: Button
@export var save_game 			: Button
@export var save_file_manager 	: SaveFileManager

func _ready():
	width.value = tile_map_builder.width
	height.value = tile_map_builder.height
	width.value_changed.connect(size_changed)
	height.value_changed.connect(size_changed)
	load_game.button_down.connect(load_game_clicked)
	save_game.button_down.connect(save_game_clicked)

func load_game_clicked():
	save_file_manager.RequestOpenGameLevelMapFile()
func save_game_clicked():
	save_file_manager.RequestSaveGameLevelMapFile()

func size_changed(new_value):
	tile_map_builder.set_new_size(width.value,height.value)
