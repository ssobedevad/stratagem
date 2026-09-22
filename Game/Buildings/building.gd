@abstract class_name Building extends Health

@export var _top_right : Vector2i
@export var _bottom_left : Vector2i
@export var _pivot : Vector2
@export var _max_health : int
@export var _health_bar : ProgressBar
@export var _hitbox : CollisionObject2D
@export var _base : Sprite2D
@export var _shop_category : SHOP_CATEGORY

var tile_pos : Vector2i
var placed : bool = false

@abstract func get_building_name() -> String
@abstract func get_description() -> String
@abstract func get_cost() -> int
@abstract func get_building_id() -> int

func get_base_texture():
	return _base.texture

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
		_health_bar.set_visible(_health < _maximum_health)
	else:
		_health_bar.value = 0
		
func _on_place():
	_hitbox.input_event.connect(_clicked)
	init_health(_max_health)
	placed = true

func _on_free():
	pass
	
func _pre_move():
	pass
	
func _post_move():
	pass

@abstract func _clicked(viewport: Viewport, event: InputEvent, shape_idx: int)
	
func kill():
	var top_right = get_top_right()
	var bottom_left = get_bottom_left()
	for x in range(bottom_left.x,top_right.x):
		for y in range(top_right.y,bottom_left.y):
			var query_pos = tile_pos + Vector2i(x,y)
			tile_map.tile_buildings[query_pos] = null
	_on_free()
	queue_free()

enum SHOP_CATEGORY {GEMS,BUILDINGS,TOWERS,TRAPS}
