class_name GameTileMap extends TileMapLayer

@export var width : int = 5
@export var height : int = 5

@export var gem_objects : Array[PackedScene]
@export var building_objects : Array[PackedScene]
@export var tower_objects : Array[PackedScene]
@export var trap_objects : Array[PackedScene]


func get_all_objects() -> Array[PackedScene]:
	var all_objects : Array[PackedScene]
	all_objects.append_array(gem_objects)
	all_objects.append_array(building_objects)
	all_objects.append_array(tower_objects)
	all_objects.append_array(trap_objects)
	return all_objects

func get_object_from_id(id : int) -> PackedScene:
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
	
func clear_board():
	clear()
	for building in tile_buildings.values():
		if building != null:
			building.queue_free()
	tile_buildings.clear()
			
func set_new_size(new_width : int, new_height : int):
	if new_width < width or new_height < height:
		clear()
	width = new_width
	height = new_height
	for x in range(-2,width + 2):
		for y in range(-2,height + 2):
			if x < 0 or y < 0 or x >= width or y >= height:
				set_cell(Vector2i (x - width/2,y - height/2),0 ,Vector2i (2,0))
			else:
				set_cell(Vector2i (x - width/2,y - height/2),0 ,Vector2i (x%2,y%2))
				if !tile_buildings.has(Vector2i (x - width/2,y - height/2)):
					tile_buildings[Vector2i (x - width/2,y - height/2)] = null

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
func write_u8(key : SAVE_DATA_KEY, value : int,
 						buffer : PackedByteArray, keys : PackedByteArray,
 						addr : Vector2i) -> Vector2i:
	keys.encode_u8(addr.y,value)
	addr.y += 1
	keys.encode_u16(addr.y,addr.x)
	addr.y += 2
	buffer.encode_u8(addr.x,value)
	addr.x += 1
	return addr
func write_s16(key : SAVE_DATA_KEY, value : int,
 						buffer : PackedByteArray, keys : PackedByteArray,
 						addr : Vector2i) -> Vector2i:
	keys.encode_u8(addr.y,key)
	addr.y += 1
	keys.encode_u16(addr.y,addr.x)
	addr.y += 2
	buffer.encode_s16(addr.x,value)
	addr.x += 2
	return addr
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
	print("FOUND MAP DATA " + str(width) + " x " + str(height))
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
	print("FOUND BUILDING " + str(id) + " AT POS " + str(tile_pos_x) + "," + str(tile_pos_y))
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
	var buffer : PackedByteArray
	var keys : PackedByteArray
	buffer.resize(65535)
	keys.resize(65535)
	var addr = Vector2i (0,0)
	addr = write_map_data_2b(buffer,keys,addr)
	var all_buildings =  all_buildings()
	for i in all_buildings.size():
		var building = all_buildings[i]
		addr = write_building_5b(building,buffer,keys,addr)
	buffer.resize(addr.x)
	keys.resize(addr.y) 
	file.store_16(addr.y) #keys_size
	file.store_buffer(keys)
	file.store_16(addr.x) #buffer_size
	file.store_buffer(buffer)
func load_map(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var key_size = file.get_16()
	var keys = file.get_buffer(key_size)
	var buffer_size = file.get_16()
	var buffer = file.get_buffer(buffer_size)
	var file_content = read_keys(keys)
	for key in file_content:
		if key.x == SAVE_DATA_KEY.MAP_DATA_2b:
			read_map_data_2b(buffer,key.y)
		if key.x == SAVE_DATA_KEY.BUILDING_5b:
			read_building_5b(buffer,key.y)	
enum SAVE_DATA_KEY {MAP_DATA_2b,BUILDING_5b}
#endregion
