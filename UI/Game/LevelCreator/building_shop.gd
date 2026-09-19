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
		building_inst.get_base_texture()
		var labels = building_list_item_inst.find_children("", "Label")
		labels[0].text = building_inst._name
		var button = building_list_item_inst.get_child(0)
		button.set_tooltip_text(building_inst._name + "\nCOST: " + str(building_inst._cost))
		var index = i
		var lambda = func():
			_button_pressed(index)
		button.pressed.connect(lambda)
		var textureRects = building_list_item_inst.find_children("", "TextureRect")
		textureRects[0].texture = building_inst.get_base_texture()
		if !building_inst is Tower:
			continue
		textureRects[1].texture = building_inst.get_gun_texture()

func _button_pressed(index: int):
	if map_builder.building_index != index:
		map_builder.building_index = index
	else:
		map_builder.building_index = -1
