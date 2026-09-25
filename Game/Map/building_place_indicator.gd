extends Node2D

@export var tile_map : TileMapLayer

var current_building : Node
var current_building_sprites :Array[Node]

func create_indicator(packed_scene : PackedScene, cell_coords : Vector2i):
	current_building = packed_scene.instantiate()
	add_child(current_building)
	if !current_building is Building: return
	current_building.global_position = tile_map.to_global(tile_map.map_to_local(cell_coords)) + current_building.get_pivot()
	current_building_sprites = current_building.find_children("", "Sprite2D")
	for node in current_building_sprites:
		node.modulate.a = 0.5
		node.modulate.b = 0
	
func update_indicator(cell_coords : Vector2i, is_move : bool = false):
	if !current_building is Building: return
	current_building.global_position = tile_map.to_global(tile_map.map_to_local(cell_coords)) + current_building.get_pivot()
	var can_place = tile_map.can_place_building(current_building,cell_coords)
	if is_move: can_place = tile_map.can_move_building(tile_map.move_building,cell_coords)
	for node in current_building_sprites:
		node.modulate.r = 0 if can_place else 1
		node.modulate.g = 1 if can_place else 0

func _process(delta: float) -> void:
	var local_pos = get_local_mouse_position()
	var cell_coords = tile_map.local_to_map(local_pos)
	var currentIdx = -1
	if current_building != null:
		currentIdx = current_building.get_building_id()
	
	if (tile_map.current_mode == GameTileMapBuilder.BUILDER_MODE.PLACE):
		var idx = tile_map.building_index
		if idx == -1 or (idx > -1 and currentIdx > -1 and idx != currentIdx):
			if current_building != null:
				current_building.queue_free()
			return
		if current_building == null:
			create_indicator(tile_map.get_current_building(),cell_coords)
		else:
			update_indicator(cell_coords)
	elif (tile_map.current_mode == GameTileMapBuilder.BUILDER_MODE.MOVE):
		if tile_map.move_building == null:
			if current_building != null:
				current_building.queue_free()
			return
		var idx = tile_map.move_building.get_building_id()
		if current_building == null:
			create_indicator(tile_map.get_object_from_id(idx),cell_coords)
		else:
			update_indicator(cell_coords,true)
	else:
		if current_building != null:
			current_building.queue_free()
