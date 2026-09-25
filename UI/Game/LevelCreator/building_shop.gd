extends Control

@export var building_list_item 	: PackedScene	
@export var gems_container 		: HBoxContainer
@export var buildings_container : HBoxContainer	
@export var towers_container 	: HBoxContainer	
@export var traps_container 	: HBoxContainer	
@export var terrain_container 	: HBoxContainer	
@export var map_builder	   		: GameTileMapBuilder

func _ready() -> void:
	for i in map_builder.get_all_objects().size():
		var building_list_item_inst = building_list_item.instantiate()
		var building_inst = map_builder.get_all_objects()[i].instantiate()
		var button = building_list_item_inst.get_child(0)
		if building_inst is Building:
			if building_inst._shop_category == Building.SHOP_CATEGORY.GEMS:
				gems_container.add_child(building_list_item_inst)
			elif building_inst._shop_category == Building.SHOP_CATEGORY.BUILDINGS:
				buildings_container.add_child(building_list_item_inst)
			elif building_inst._shop_category == Building.SHOP_CATEGORY.TOWERS:
				towers_container.add_child(building_list_item_inst)
			elif building_inst._shop_category == Building.SHOP_CATEGORY.TRAPS:
				traps_container.add_child(building_list_item_inst)
			button.text = building_inst.get_building_name() + "\nCOST: " + str(building_inst.get_cost())
			button.set_tooltip_text(building_inst.get_description())
			button.pressed.connect(func(): _button_pressed(building_inst.get_building_id()))
		elif building_inst is Terrain:
			terrain_container.add_child(building_list_item_inst)
			button.text = building_inst._name
			button.pressed.connect(func(): _terrain_button_pressed(building_inst.get_building_id()))

func _button_pressed(index: int):
	if map_builder.building_index != index or map_builder.current_mode != GameTileMapBuilder.BUILDER_MODE.PLACE:
		map_builder.building_index = index
	else:
		map_builder.building_index = -1
	map_builder.current_mode = GameTileMapBuilder.BUILDER_MODE.PLACE

func _terrain_button_pressed(index: int):
	if map_builder.building_index != index or map_builder.current_mode != GameTileMapBuilder.BUILDER_MODE.PLACE:
		map_builder.building_index = index
	else:
		map_builder.building_index = -1
	map_builder.current_mode = GameTileMapBuilder.BUILDER_MODE.PLACE
