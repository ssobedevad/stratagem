class_name GameTileMap extends TileMapLayer

@export var height := 5
@export var width := 5

var tileBuildings : Dictionary[Vector2i, Building]

func _ready() -> void:
	for x in width:
		for y in height:
			set_cell(Vector2i (x - width/2,y - height/2),0 ,Vector2i (x%2,y%2))
			tileBuildings[Vector2i (x - width/2,y - height/2)] = null
