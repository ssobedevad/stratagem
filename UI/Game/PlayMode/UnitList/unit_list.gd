extends Node

@export var _item_list : ItemList
@export var _tile_map : GameTileMapPlay

func _ready() -> void:
	var units = _tile_map.unit_objects
	_item_list.item_selected.connect(_item_selected)
	for unit in units:
		var unit_inst = unit.instantiate()
		var unit_script = unit_inst as Unit
		var unit_sprite : Sprite2D = unit_inst.get_node("./Icon")
		_item_list.add_item(unit_script.get_unit_name(), unit_sprite.texture)

func _item_selected(index : int):
	_tile_map.unit_index = index
