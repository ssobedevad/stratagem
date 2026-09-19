extends FoldableContainer

@export var building_list_item 	: PackedScene	
@export var hbox_container 		: HBoxContainer	
@export var map_builder	   		: GameTileMapBuilder

func _ready() -> void:
	for i in map_builder.building_objects.size():
		var building_list_item_inst = building_list_item.instantiate()
		var building_inst = map_builder.building_objects[i].instantiate()
		if !building_inst is Building:
			continue
		hbox_container.add_child(building_list_item_inst)
		var button = building_list_item_inst.get_child(0)
		button.text = building_inst._name + "\nCOST: " + str(building_inst._cost)
		button.set_tooltip_text(str(building_inst._description))
		button.pressed.connect(func(): _button_pressed(i))

func _button_pressed(index: int):
	if map_builder.building_index != index:
		map_builder.building_index = index
	else:
		map_builder.building_index = -1
