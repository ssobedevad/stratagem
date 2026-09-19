class_name GameTileMapBuilder extends GameTileMap

@export var building_objects : Array[PackedScene]
@export var building_index := -1

func _ready() -> void:
	super()

func has_current_building() -> bool:
	return building_index > -1

func get_current_building() -> PackedScene:
	return building_objects[building_index]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()
		var cell_coords = local_to_map(local_pos)
		var source_id = get_cell_source_id(cell_coords)
		if source_id != -1 && has_current_building():
			_place_building(cell_coords)
			
func can_place_building(building: Building, pos: Vector2i) -> bool:
	if not building is Building:
		return false
	var top_right = building.get_top_right()
	var bottom_left = building.get_bottom_left()
	for x in range(bottom_left.x,top_right.x):
		for y in range(top_right.y,bottom_left.y):
			var query_pos = pos + Vector2i(x,y)
			if !tileBuildings.has(query_pos) || tileBuildings[query_pos] != null :
				return false
	return true

func _can_place_building(pos: Vector2i) -> bool:
	var building = building_objects[building_index].instantiate()
	if not building is Building:
		print("NOT VALID")
		return false
	return can_place_building(building,pos)

func _place_building(pos: Vector2i) -> bool:
	if (!has_current_building() || _can_place_building(pos) == false):
		return false
	var global_cell_pos = map_to_local(pos)
	var building_inst = building_objects[building_index].instantiate()
	if building_inst is Building:
		global_cell_pos += building_inst.get_pivot()
		building_inst.global_position = global_cell_pos
		building_inst._on_place()
		add_child(building_inst)
		var top_right = building_inst.get_top_right()
		var bottom_left = building_inst.get_bottom_left()
		for x in range(bottom_left.x,top_right.x):
			for y in range(top_right.y,bottom_left.y):
				var query_pos = pos + Vector2i(x,y)
				if tileBuildings.has(query_pos):
					tileBuildings[query_pos] = building_inst
	return true
