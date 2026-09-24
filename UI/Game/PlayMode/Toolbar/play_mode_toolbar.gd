extends Panel

@export var tile_map_play 			: GameTileMapPlay
@export var home_button 			: Button

func _ready():
	home_button.button_down.connect(home_button_clicked)

func home_button_clicked():
	get_tree().change_scene_to_file("res://Scenes/level_creator.tscn")
