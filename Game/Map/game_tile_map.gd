class_name GameTileMap extends TileMapLayer

@export var width : int = 5
@export var height : int = 5

var gem_objects : Array[PackedScene]
var building_objects : Array[PackedScene]
var tower_objects : Array[PackedScene]
var trap_objects : Array[PackedScene]
var terrain_objects : Array[PackedScene]

var unit_objects : Array[PackedScene]

func get_all_objects() -> Array[PackedScene]:
	var all_objects : Array[PackedScene]
	all_objects.append_array(gem_objects)
	all_objects.append_array(building_objects)
	all_objects.append_array(tower_objects)
	all_objects.append_array(trap_objects)
	all_objects.append_array(terrain_objects)
	return all_objects

func get_object_from_id(id : int) -> PackedScene:
	if id >= 150:
		return terrain_objects[id - 150]
	if id >= 100:
		return trap_objects[id - 100]
	if id >= 50:
		return tower_objects[id - 50]
	if id >= 10:
		return building_objects[id - 10]
	return gem_objects[id]

@export var buildings_node : Node
@export var units_node : Node

var tile_buildings 	: Dictionary[Vector2i, Building]
func all_buildings()-> Array[Building]:
	var buildings : Array[Building]
	for building in buildings_node.get_children():
		if building != null and building is Building:
			buildings.append(building)
	return buildings

var all_targettable	: Array[Health]

func _ready() -> void:
	clear_board()
	set_new_size(width,height)
	var bdb : BuildingDatabase = Autoload.get_node("./BuildingDatabase")
	gem_objects = bdb.gem_objects
	building_objects = bdb.building_objects
	tower_objects = bdb.tower_objects
	trap_objects = bdb.trap_objects
	terrain_objects = bdb.terrain_objects
	var udb : UnitDatabase = Autoload.get_node("./UnitDatabase")
	unit_objects = udb.unit_objects
	if (Autoload as AutoloadGlobalData).loading_map_data.size() == 2:
		load_map_from_buffers((Autoload as AutoloadGlobalData).loading_map_data)
	
func clear_board():
	clear()
	for building in tile_buildings.values():
		if building != null:
			building.queue_free()
	tile_buildings.clear()
			
func set_new_size(new_width : int, new_height : int):
	if new_width < width:
		print("BOARD SHRINK WIDTH: " + str(range(new_width,width)))
		clear()
		for x in range(new_width,width):
			for y in range(0,height):
				if tile_buildings[Vector2i (x,y)] != null:
					tile_buildings[Vector2i (x,y)].kill()
				tile_buildings.erase(Vector2i (x,y))	
				print("REMOVE TILE " + str(Vector2i (x,y)))
	if new_height < height:
		print("BOARD SHRINK HEIGHT: " + str(range(new_height,height)))
		clear()
		for x in range(0,width):
			for y in range(new_height,height):
				if tile_buildings[Vector2i (x,y)] != null:
					tile_buildings[Vector2i (x,y)].kill()
				tile_buildings.erase(Vector2i (x,y))	
				print("REMOVE TILE " + str(Vector2i (x,y)))
	width = new_width
	height = new_height
	for x in range(-2,width + 2):
		for y in range(-2,height + 2):
			if x < 0 or y < 0 or x >= width or y >= height:
				set_cell(Vector2i (x,y),0 ,Vector2i (4,0))
			else:
				set_cell(Vector2i (x,y),0 ,Vector2i (x%2,y%2))
				if !tile_buildings.has(Vector2i (x,y)):
					tile_buildings[Vector2i (x,y)] = null

func can_place_building(building: Building, pos: Vector2i) -> bool:
	if not building is Building:
		return false
	var top_right = building.get_top_right()
	var bottom_left = building.get_bottom_left()
	for x in range(bottom_left.x,top_right.x):
		for y in range(top_right.y,bottom_left.y):
			var query_pos = pos + Vector2i(x,y)
			if !tile_buildings.has(query_pos) || tile_buildings[query_pos] != null:
				return false
	return true

func spawn_building(buildingID : int, pos : Vector2i):
	if buildingID < 0: return
	var global_cell_pos = map_to_local(pos)
	var building_inst = get_object_from_id(buildingID).instantiate()
	if !can_place_building(building_inst,pos): return false
	if building_inst is Building:
		global_cell_pos += building_inst.get_pivot()
		building_inst.global_position = global_cell_pos
		building_inst.tile_pos = pos
		buildings_node.add_child(building_inst)
		var top_right = building_inst.get_top_right()
		var bottom_left = building_inst.get_bottom_left()
		for x in range(bottom_left.x,top_right.x):
			for y in range(top_right.y,bottom_left.y):
				var query_pos = pos + Vector2i(x,y)
				if tile_buildings.has(query_pos):
					tile_buildings[query_pos] = building_inst
		building_inst._on_place()
	return true

#region save_load
func write_map_data_2b(buffer : PackedByteArray, keys : PackedByteArray,
 						addr : Vector2i) -> Vector2i:
	keys.encode_u8(addr.y,SAVE_DATA_KEY.MAP_DATA_2b)
	addr.y += 1
	keys.encode_u16(addr.y,addr.x)
	addr.y += 2
	buffer.encode_u8(addr.x,width)
	addr.x += 1
	buffer.encode_u8(addr.x,height)
	addr.x += 1
	return addr
func read_map_data_2b(buffer : PackedByteArray, addr : int) -> void:
	width = buffer.decode_u8(addr)
	addr += 1
	height = buffer.decode_u8(addr)
	addr += 1
	set_new_size(width,height)
func write_tile_5b(pos : Vector2i,
 						buffer : PackedByteArray, keys : PackedByteArray,
 						addr : Vector2i) -> Vector2i:
	keys.encode_u8(addr.y,SAVE_DATA_KEY.TILE_DATA_5b)
	addr.y += 1
	keys.encode_u16(addr.y,addr.x)
	addr.y += 2
	buffer.encode_u8(addr.x,get_cell_atlas_coords(pos).x)
	addr.x += 1
	buffer.encode_s16(addr.x,pos.x)
	addr.x += 2
	buffer.encode_s16(addr.x,pos.y)
	addr.x += 2
	print("WRITE TILE " +str(pos) + " WITH TEX COORD " + str(get_cell_atlas_coords(pos)))
	return addr
func read_tile_5b(buffer : PackedByteArray, addr : int) -> void:
	var id = buffer.decode_u8(addr)
	addr += 1
	var tile_pos_x = buffer.decode_s16(addr)
	addr += 2
	var tile_pos_y = buffer.decode_s16(addr)
	addr += 2
	var pos = Vector2i (tile_pos_x,tile_pos_y)
	var coords = get_cell_atlas_coords(pos)
	set_cell(pos,0,Vector2i(id,coords.y))	
	print("READ TILE " +str(pos) + " WITH TEX COORD " + str(Vector2i(id,coords.y)))
func write_building_5b(building : Building,
 						buffer : PackedByteArray, keys : PackedByteArray,
 						addr : Vector2i) -> Vector2i:
	keys.encode_u8(addr.y,SAVE_DATA_KEY.BUILDING_5b)
	addr.y += 1
	keys.encode_u16(addr.y,addr.x)
	addr.y += 2
	buffer.encode_u8(addr.x,building.get_building_id())
	addr.x += 1
	buffer.encode_s16(addr.x,building.tile_pos.x)
	addr.x += 2
	buffer.encode_s16(addr.x,building.tile_pos.y)
	addr.x += 2
	return addr
func read_building_5b(buffer : PackedByteArray, addr : int) -> void:
	var id = buffer.decode_u8(addr)
	addr += 1
	var tile_pos_x = buffer.decode_s16(addr)
	addr += 2
	var tile_pos_y = buffer.decode_s16(addr)
	addr += 2
	spawn_building(id,Vector2i (tile_pos_x,tile_pos_y))
func read_keys(keys : PackedByteArray) -> Array[Vector2i]:
	var addr = 0
	var keys_content : Array[Vector2i]
	while addr < keys.size():
		var key = keys.decode_u8(addr)
		addr += 1
		var value = keys.decode_u16(addr)
		addr += 2
		keys_content.append(Vector2i (key,value))
	return keys_content
func save_map(file_path):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var datas = get_save_game_buffers()
	file.store_16(datas[0].size()) #Keys
	file.store_buffer(datas[0])
	file.store_16(datas[1].size()) #Buffer
	file.store_buffer(datas[1])

func get_save_game_buffers() -> Array[PackedByteArray]:
	var buffer : PackedByteArray
	var keys : PackedByteArray
	buffer.resize(65535)
	keys.resize(65535)
	var addr = Vector2i (0,0)
	addr = write_map_data_2b(buffer,keys,addr)
	var all_buildings =  all_buildings()
	
	for x in width:
		for y in height:
			var pos = Vector2i(x,y)
			if get_cell_atlas_coords(pos).x >= 2:
				addr = write_tile_5b(pos,buffer,keys,addr)
				
	for i in all_buildings.size():
		var building = all_buildings[i]
		addr = write_building_5b(building,buffer,keys,addr)
		
	buffer.resize(addr.x)
	keys.resize(addr.y) 
	return [keys,buffer]

func load_map(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var key_size = file.get_16()
	var keys = file.get_buffer(key_size)
	var buffer_size = file.get_16()
	var buffer = file.get_buffer(buffer_size)
	load_map_from_buffers([keys,buffer])
	
enum SAVE_DATA_KEY {MAP_DATA_2b,BUILDING_5b,TILE_DATA_5b}

func load_map_from_buffers(save_game_buffers : Array[PackedByteArray]):
	var keys = save_game_buffers[0]
	var buffer = save_game_buffers[1]
	var file_content = read_keys(keys)
	for key in file_content:
		print("DO KEY" + str(key.x))
		if key.x == SAVE_DATA_KEY.MAP_DATA_2b:
			read_map_data_2b(buffer,key.y)
		elif key.x == SAVE_DATA_KEY.BUILDING_5b:
			read_building_5b(buffer,key.y)	
		elif key.x == SAVE_DATA_KEY.TILE_DATA_5b:
			print("READ TILE 5b")
			read_tile_5b(buffer,key.y)	
		else:
			print("UNKNOWN KEY" + str(key.x))
#endregion
