class_name CameraMovement extends Camera2D

var move_speed = 400 
var zoom_speed = 10 

var paused : bool = false

@export var tile_map : GameTileMap

func _ready() -> void:
	global_position.x = tile_map.global_position.x + tile_map.width * 8
	global_position.y = tile_map.global_position.y + tile_map.height * 8

func _process(delta: float) -> void:
	if paused: return
	var current_zoom = zoom.x
	var current_position = global_position
	if Input.is_action_pressed("Camera Up"):
		current_position.y -= delta * move_speed/current_zoom;
	if Input.is_action_pressed("Camera Down"):
		current_position.y += delta * move_speed/current_zoom;
	if Input.is_action_pressed("Camera Left"):
		current_position.x -= delta * move_speed/current_zoom;
	if Input.is_action_pressed("Camera Right"):
		current_position.x += delta * move_speed/current_zoom;
	if Input.is_action_just_pressed("Camera Zoom In"):
		current_zoom += delta * zoom_speed
	if Input.is_action_just_pressed("Camera Zoom Out"):
		current_zoom -= delta * zoom_speed
	global_position.x = clampf(current_position.x,tile_map.global_position.x - tile_map.width * 8, tile_map.global_position.x + tile_map.width * 16)
	global_position.y = clampf(current_position.y,tile_map.global_position.y - tile_map.height * 8, tile_map.global_position.y + tile_map.height * 16)
	zoom.x = clampf(current_zoom,0.1,2);
	zoom.y = clampf(current_zoom,0.1,2);
