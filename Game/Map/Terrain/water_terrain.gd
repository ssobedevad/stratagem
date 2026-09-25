extends Terrain

func _on_place(pos : Vector2i, tile_map : GameTileMap):
	var coords = tile_map.get_cell_atlas_coords(pos)
	if coords.x < 2:
		tile_map.set_cell(pos, 0,coords + Vector2i (4,0))

func get_building_id():
	return 150
