class_name GameTileMapBuilder extends GameTileMap

var building_index : int = -1

var current_mode : BUILDER_MODE

var move_building : Building

enum BUILDER_MODE {PLACE, MOVE, DELETE}

func _ready() -> void:
	super()

func has_current_building() -> bool:
	return building_index > -1

func get_current_building() -> PackedScene:
	return get_object_from_id(building_index)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()
		var cell_coords = local_to_map(local_pos)
		var source_id = get_cell_source_id(cell_coords)
		if source_id == -1: return
		if has_current_building() && current_mode == BUILDER_MODE.PLACE:
			_place_building(cell_coords)
		if tile_buildings.has(cell_coords):
			if tile_buildings[cell_coords] != null:
				if current_mode == BUILDER_MODE.DELETE:
					remove_building(tile_buildings[cell_coords])
				elif current_mode == BUILDER_MODE.MOVE:
					if move_building == null or tile_buildings[cell_coords] != move_building:
						move_building = tile_buildings[cell_coords]
					else:
						if try_move(cell_coords): move_building = null
			elif move_building != null and current_mode == BUILDER_MODE.MOVE:
				if try_move(cell_coords): move_building = null

func remove_building(building : Building, free : bool = true):
	var top_right = building.get_top_right() #REMOVE FROM OLD POS
	var bottom_left = building.get_bottom_left()
	for x in range(bottom_left.x,top_right.x):
		for y in range(top_right.y,bottom_left.y):
			var query_pos = building.tile_pos + Vector2i(x,y)
			tile_buildings[query_pos] = null	
	building._on_free()
	if free:
		building.queue_free()


func try_move(pos: Vector2i):
	print("TRYING TO MOVE " + str(move_building) + " FROM " + str(move_building.tile_pos) + " TO " +str(pos))
	if move_building == null: return false
	print("TRY CAN MOVE")
	if !can_move_building(move_building,pos): return false
	print("CAN MOVE SUCCESS")
	remove_building(move_building,false)
	move_building._pre_move()
	print("REMOVAL COMPLETE")
	var global_cell_pos = to_global(map_to_local(pos)) + move_building.get_pivot() #ADD TO NEW POS
	var top_right = move_building.get_top_right() #REMOVE FROM OLD POS
	var bottom_left = move_building.get_bottom_left()
	move_building.global_position = global_cell_pos
	move_building.tile_pos = pos
	for x in range(bottom_left.x,top_right.x):
		for y in range(top_right.y,bottom_left.y):
			var query_pos = move_building.tile_pos + Vector2i(x,y)
			tile_buildings[query_pos] = move_building
	move_building._post_move()
	print("ADD COMPLETE")
	return true
	
func can_move_building(building: Building, pos: Vector2i) -> bool:
	if not building is Building:
		return false
	var top_right = building.get_top_right()
	var bottom_left = building.get_bottom_left()
	for x in range(bottom_left.x,top_right.x):
		for y in range(top_right.y,bottom_left.y):
			var query_pos = pos + Vector2i(x,y)
			if !tile_buildings.has(query_pos) || (tile_buildings[query_pos] != null and tile_buildings[query_pos] != building):
				return false
	return true

func _can_place_building(pos: Vector2i) -> bool:
	var building = get_object_from_id(building_index).instantiate()
	if not building is Building:
		print("NOT VALID")
		return false
	return can_place_building(building,pos)

func _place_building(pos: Vector2i) -> bool:
	var building = get_object_from_id(building_index).instantiate()
	if building is Building:
		if (!has_current_building() || _can_place_building(pos) == false):
			return false
		spawn_building(building_index, pos)
	elif building is Terrain:
		building._on_place(pos,self)
	return true
	
