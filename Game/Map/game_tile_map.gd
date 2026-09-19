class_name GameTileMap extends TileMapLayer

@export var width : int = 5
@export var height : int = 5

var tile_buildings 	: Dictionary[Vector2i, Building]
var all_buildings	: Array[Building]

func _ready() -> void:
	for x in width:
		for y in height:
			set_cell(Vector2i (x - width/2,y - height/2),0 ,Vector2i (x%2,y%2))
			tile_buildings[Vector2i (x - width/2,y - height/2)] = null

func save_map(file_path):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var buffer : PackedByteArray
	var byte_index = 0
	buffer.resize(2048)
	buffer.encode_u8(byte_index,width) 
	byte_index += 8
	buffer.encode_u8(byte_index,height)
	byte_index += 8
	buffer.encode_u8(byte_index,all_buildings.size())
	byte_index += 8
	for i in all_buildings.size():
		var building = all_buildings[i]
		buffer.encode_s16(byte_index,building.get_building_id())
		byte_index += 16
		buffer.encode_s16(byte_index,building.tile_pos.x)
		byte_index += 16
		buffer.encode_s16(byte_index,building.tile_pos.y)
		byte_index += 16
	buffer.resize(byte_index)
	file.store_buffer(buffer)
	
func load_map(file_path):
	var buffer = FileAccess.get_file_as_bytes(file_path)
	var byte_index = 0
	width = buffer.decode_u8(byte_index) 
	byte_index += 8
	height = buffer.decode_u8(byte_index) 
	byte_index += 8
	var array_size = buffer.decode_u8(byte_index) 
	byte_index += 8
	print("FOUND TILEMAP " + str(width) + " x " + str(height)  + " WITH " + str(array_size) + " BUILDINGS")
	for i in array_size:
		var id = buffer.decode_s16(byte_index)
		byte_index += 16
		var tile_pos_x = buffer.decode_s16(byte_index)
		byte_index += 16
		var tile_pos_y = buffer.decode_s16(byte_index)
		byte_index += 16
		print("FOUND BUILDING " + str(id) + " AT POS " + str(tile_pos_x) + "," + str(tile_pos_y))
