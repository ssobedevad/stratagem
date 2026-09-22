class_name GameTileMapPlay extends GameTileMap

var unit_index : int = -1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()
		var cell_coords = local_to_map(local_pos)
		var source_id = get_cell_source_id(cell_coords)
		print("CLICKED " + str(cell_coords))
		if source_id == -1: return
		if unit_index < 0: return
		spawn_unit(unit_index,cell_coords)
	
func spawn_unit(unitID : int, pos : Vector2i):
	if unitID < 0: return
	var global_cell_pos = map_to_local(pos)
	var unit_inst = unit_objects[unitID].instantiate()
	if unit_inst is Unit:
		unit_inst.global_position = global_cell_pos
		units_node.add_child(unit_inst)
	return true
