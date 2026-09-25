class_name GameTileMapPlay extends GameTileMap

var unit_index : int = -1

var stop_place : Dictionary[Vector2i, bool]

func _has_building_in_range(pos : Vector2i, range : int):
	for x in range(-range,range + 1):
		for y in range(-range,range + 1):
			var target_pos = pos + Vector2i(x,y)
			if tile_buildings.has(target_pos) and tile_buildings[target_pos] != null:
				return true
	return false

func _ready() -> void:
	super()
	for tile in tile_buildings:
		var has_build = _has_building_in_range(tile,1)
		stop_place[tile] = has_build
		if has_build:
			var coords = get_cell_atlas_coords(tile)
			set_cell(tile, 0,coords + Vector2i (2,0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()
		var cell_coords = local_to_map(local_pos)
		var source_id = get_cell_source_id(cell_coords)
		if source_id == -1: return
		if unit_index < 0: return
		if stop_place.has(cell_coords) and stop_place[cell_coords]:
			print("STOP PLACE")
			return
		spawn_unit(unit_index,to_global(local_pos))
	
func spawn_unit(unitID : int, pos : Vector2):
	if unitID < 0: return
	var unit_inst = unit_objects[unitID].instantiate()
	if unit_inst is Unit:
		units_node.add_child(unit_inst)
		unit_inst.global_position = pos
	return true
