@abstract class_name Building extends Health

@export var _top_right : Vector2i
@export var _bottom_left : Vector2i
@export var _pivot : Vector2
@export var _max_health : int
@export var _health_bar : ProgressBar
@export var _hitbox : CollisionObject2D
@export var _base : Sprite2D
@export var _name : String
@export var _cost : int
@export var _description : String

var tile_pos : Vector2i

var placed : bool = false

func get_building_id() -> int:
	return -1

func get_base_texture():
	return _base.texture

func on_place():
	pass

func get_pivot() -> Vector2:
	return _pivot	
	
func get_size() -> Vector2i:
	return _top_right - _bottom_left
	
func get_top_right() -> Vector2i:
	return _top_right
	
func get_bottom_left() -> Vector2i:
	return _bottom_left
		
func _process(delta):
	if _maximum_health > 0:
		_health_bar.value = float (_health)/ float (_maximum_health) * 100.0
	else:
		_health_bar.value = 0
func _on_place():
	_hitbox.input_event.connect(_clicked)
	init_health(_max_health)
	placed = true

@abstract func _clicked(viewport: Viewport, event: InputEvent, shape_idx: int)
	
func kill():
	pass
