extends Node2D

@export var tile_map : TileMapLayer

var current_building : Building
var current_building_sprites :Array[Node]

func _process(delta: float) -> void:
	if tile_map.has_current_building() == false:
		if current_building != null:
			current_building.queue_free()
		return

	var local_pos = get_local_mouse_position()
	var cell_coords = tile_map.local_to_map(local_pos)
	var source_id = tile_map.get_cell_source_id(cell_coords)
	if current_building == null:
		current_building = tile_map.get_current_building().instantiate()
		current_building.global_position = tile_map.to_global(tile_map.map_to_local(cell_coords)) + current_building.get_pivot()
		current_building_sprites = current_building.find_children("", "Sprite2D")
		for node in current_building_sprites:
			node.modulate.a = 0.5
			node.modulate.b = 0
		current_building._range_indicator.set_visible(true)
		add_child(current_building)
	else:
		current_building.global_position = tile_map.to_global(tile_map.map_to_local(cell_coords)) + current_building.get_pivot()
		var can_place = tile_map.can_place_building(current_building,cell_coords)
		for node in current_building_sprites:
			node.modulate.r = 0 if can_place else 1
			node.modulate.g = 1 if can_place else 0
