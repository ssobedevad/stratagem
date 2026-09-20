@abstract class_name Unit extends Health

@export var _max_health : int
@export var _range : float
@export var _move_speed : float
@export var _attack_speed : float
@export var _attack_damage : int
@export var _hitbox : RigidBody2D
@export var _navigator : NavigationAgent2D
@export var _health_bar : ProgressBar

var _attack_timer : float
var _attack_time : float

func _ready():
	init_health(_max_health)
	_hitbox.input_event.connect(_clicked)
	_navigator.target_desired_distance = (_range + 1) * 16
	_attack_time = 100 if _attack_speed == 0 else 1/_attack_speed 

func kill():
	queue_free()
	
func _process(delta):
	if _maximum_health > 0:
		_health_bar.value = float (_health)/ float (_maximum_health) * 100.0
		_health_bar.set_visible(_health < _maximum_health)
	else:
		_health_bar.value = 0
	
func valid_target(possible : Health) -> bool:
	if !possible is Building: return false
	return true

func _clicked(viewport: Viewport, event: InputEvent, shape_idx: int):
	pass
	
@abstract func attack()

func _physics_process(delta: float) -> void:
	if target == null:
		_navigator.target_position = global_position
		_attack_timer = 0
		get_target()
	else:
		_navigator.target_position = target.global_position
		if target is Building:
			if target._hitbox.shape_owner_get_shape(0,0) is CircleShape2D:
				var circle = target._hitbox.shape_owner_get_shape(0,0) as CircleShape2D
				_navigator.target_desired_distance = (_range + 0.5) * 16 + circle.radius
		if _navigator.distance_to_target() < _navigator.target_desired_distance * 1.1:
			_attack_timer += delta
			if (_attack_timer >= _attack_time):
				_attack_timer -= _attack_time
				attack()
		else:
			_attack_timer = 0
	if !_navigator.is_navigation_finished():
		_hitbox.linear_velocity = (_navigator.get_next_path_position() - global_position).normalized() * 10 *  _move_speed
