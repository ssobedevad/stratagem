@abstract class_name Tower extends Building

@export var _gun : Sprite2D
@export var _range_indicator : Sprite2D
@export var _range : float
@export var _attack_speed : float
@export var _damage : int
@export var _target_mode : target_mode

var _attack_timer : float
var _attack_time : float

enum target_mode {GROUND,AIR,GROUND_AND_AIR}

func _range_pixels():
	return (_range * 16 + 16)

func get_gun_texture():
	return _gun.texture

func _ready():
	var _rangeScaling = 0.027 * (_range + 1)
	_range_indicator.scale = Vector2 (_rangeScaling,_rangeScaling)
	_attack_time = 100 if _attack_speed == 0 else 1/_attack_speed 
	
func _on_place():
	super()
	_range_indicator.set_visible(false)

func _clicked(viewport: Viewport, event: InputEvent, shape_idx: int):
	if !placed: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var visibility = !_range_indicator.is_visible()
			_range_indicator.set_visible(visibility)

func valid_target(possible : Health) -> bool:
	if !possible is Unit: return false
	if possible._flying and _target_mode == target_mode.GROUND: return false
	if !possible._flying and _target_mode == target_mode.AIR: return false
	var dist = (possible.global_position - global_position).length()
	if dist > _range_pixels(): return false
	return true

func get_target():
	var possible = tile_map.all_targettable
	var current_dist = INT32_MAX
	var current_target = null
	for new_target in possible:
		if new_target == null: continue
		if !can_target(new_target) or !valid_target(new_target): continue
		var dist = (new_target.global_position - global_position).length()
		if dist < current_dist:
			current_target = new_target
			current_dist = dist
	target = current_target
