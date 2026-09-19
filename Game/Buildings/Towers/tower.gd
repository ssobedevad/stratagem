@abstract class_name Tower extends Building

@export var _gun : Sprite2D
@export var _range_indicator : Sprite2D
@export var _range : float

@abstract func get_target()

func get_gun_texture():
	return _gun.texture

func _ready():
	var _rangeScaling = 0.027 * (_range + 1)
	_range_indicator.scale = Vector2 (_rangeScaling,_rangeScaling)
	
func _on_place():
	super()

func _clicked(viewport: Viewport, event: InputEvent, shape_idx: int):
	if !placed: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var visibility = !_range_indicator.is_visible()
			_range_indicator.set_visible(visibility)
			_health_bar.set_visible(visibility)
