@abstract class_name Terrain extends Node

@export var _icon : Texture2D
@export var _name : String

@abstract func _on_place(pos : Vector2i, tile_map : GameTileMap)

@abstract func get_building_id()
