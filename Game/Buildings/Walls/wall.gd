class_name Wall extends Building

@export var wall_frames : Sprite2D

func _clicked(viewport: Viewport, event: InputEvent, shape_idx: int):
	pass

func get_building_name() -> String:
	return "Wall"

func get_description() -> String:
	return "A sturdy barrier to slow down ground units."

func get_cost() -> int:
	return 50
	
func get_building_id() -> int:
	return 10

func _on_place():
	super()
	_update_wall_frame(true)
	
func _on_free():
	_update_wall_frame(true)
	
func _pre_move():
	_update_wall_frame(true)
	
func _post_move():
	_update_wall_frame(true)

func has_wall(pos : Vector2i, update : bool):
	var is_wall =  tile_map.tile_buildings.has(pos) and tile_map.tile_buildings[pos] != null and tile_map.tile_buildings[pos] is Wall
	if is_wall and update:
		tile_map.tile_buildings[pos]._update_wall_frame()
		#print("UPDATED BY NEIGHBOUR " + str(pos))
	return is_wall

func _update_wall_frame(update_neighbours : bool = false):
	var has_above = has_wall(tile_pos + Vector2i(0,-1),update_neighbours)
	var has_below = has_wall(tile_pos + Vector2i(0,1),update_neighbours)
	var has_left = has_wall(tile_pos + Vector2i(-1,0),update_neighbours)
	var has_right = has_wall(tile_pos + Vector2i(1,0),update_neighbours)
	#print("WALL AT POS " + str(tile_pos) + " STATUS A: " + str(has_above) + " B: " + str(has_below) + " L: " + str(has_left) + " R: " + str(has_right))
	if has_above:
		if has_below:
			if has_left:
				if has_right:
					wall_frames.frame_coords = Vector2i(3,3)
				else:
					wall_frames.frame_coords = Vector2i(2,3)
			else:
				if has_right:
					wall_frames.frame_coords = Vector2i(0,3)
				else:
					wall_frames.frame_coords = Vector2i(2,1)
		else:
			if has_left:
				if has_right:
					wall_frames.frame_coords = Vector2i(3,2)
				else:
					wall_frames.frame_coords = Vector2i(3,1)
			else:
				if has_right:
					wall_frames.frame_coords = Vector2i(1,1)
				else:
					wall_frames.frame_coords = Vector2i(1,0)
	else:
		if has_below:
			if has_left:
				if has_right:
					wall_frames.frame_coords = Vector2i(1,3)
				else:
					wall_frames.frame_coords = Vector2i(2,2)
			else:
				if has_right:
					wall_frames.frame_coords = Vector2i(0,2)
				else:
					wall_frames.frame_coords = Vector2i(3,0)
		else:
			if has_left:
				if has_right:
					wall_frames.frame_coords = Vector2i(1,2)
				else:
					wall_frames.frame_coords = Vector2i(2,0)
			else:
				if has_right:
					wall_frames.frame_coords = Vector2i(0,1)
				else:
					wall_frames.frame_coords = Vector2i(0,0)
	
