@abstract class_name Unit extends Health

@export var _max_health : int
@export var _range : float
@export var _move_speed : float
@export var _attack_speed : float
@export var _attack_damage : int
@export var _hitbox : RigidBody2D
@export var _health_bar : ProgressBar

var _attack_timer : float
var _attack_time : float

var _current_path : Array[Vector2]

@abstract func get_unit_name() -> String
@abstract func get_description() -> String
@abstract func get_cost() -> int
@abstract func get_unit_id() -> int

func get_wall_target_cost():
	return 20

func _ready():
	init_health(_max_health)
	_hitbox.input_event.connect(_clicked)
	_attack_time = 100 if _attack_speed == 0 else 1/_attack_speed 

func _get_tile_pos() -> Vector2i:
	var local_pos = global_position - tile_map.global_position
	return tile_map.local_to_map(local_pos)
	
func _has_tile_at_pos(pos : Vector2i):
	return tile_map.get_cell_source_id(pos) > -1;
	
func _get_global_pos(tile_pos : Vector2i) -> Vector2:
	var local_pos = tile_map.map_to_local(tile_pos)
	return tile_map.to_global(local_pos)

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
	
func get_range():
	var base_range =  (_range) * 16
	if target != null:
		if target is Building:
			if target._hitbox.shape_owner_get_shape(0,0) is CircleShape2D:
				var circle = target._hitbox.shape_owner_get_shape(0,0) as CircleShape2D
				return base_range + circle.radius + 8
	return base_range + 16;
	
func get_range_to_target(to_target : Health):
	var base_range =  (_range) * 16
	if to_target != null:
		if to_target is Building:
			if to_target._hitbox.shape_owner_get_shape(0,0) is CircleShape2D:
				var circle = to_target._hitbox.shape_owner_get_shape(0,0) as CircleShape2D
				return base_range + circle.radius + 8
	return base_range + 16;

func _clicked(viewport: Viewport, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_set_route_and_target()
	
@abstract func attack()

func _physics_process(delta: float) -> void:
	if target == null:
		_set_route_and_target()
		_hitbox.linear_velocity = Vector2.ZERO
	else:
		if _current_path.size() > 0:
			if (_current_path[0] - global_position).length() > 1:
				_hitbox.linear_velocity = (_current_path[0] - global_position).normalized() * 10 * _move_speed
			else:
				_set_route_and_target()
		else:
			if (target.global_position - global_position).length() > get_range():
				_hitbox.linear_velocity = (target.global_position - global_position).normalized() * 10 * _move_speed
		if (target.global_position - global_position).length() < get_range():
			_hitbox.linear_velocity = Vector2.ZERO
			_attack_timer += delta
			if (_attack_timer >= _attack_time):
				_attack_timer -= _attack_time
				attack()
		else:
			_attack_timer = 0

#region Pathfinding
var tile_neighbors : Array[Vector2i] = [
	Vector2i(-1, 1), Vector2i( 0, 1), Vector2i( 1, 1),
	Vector2i(-1, 0),                  Vector2i( 1, 0),
	Vector2i(-1,-1), Vector2i( 0,-1), Vector2i( 1,-1),
	]

func find_targets() -> Array[Target]:
	var possible = tile_map.all_targettable
	var targets : Array[Target]
	for new_target in possible:
		if new_target == null: continue
		if !can_target(new_target) or !valid_target(new_target): continue
		var isWall = new_target is Wall
		var cost = 1
		if isWall: cost = get_wall_target_cost()
		cost += GetHeuristic(new_target._get_tile_pos(),_get_tile_pos())
		targets.append(Target.new(new_target,cost))
	return targets

func _set_route_and_target():
	var best_path : Array[Vector2]
	var best_cost : int = INT32_MAX
	var start_pos = _get_tile_pos()
	var targets = find_targets()
	for t in targets:
		if t.cost > best_cost: continue
		var came_from : Dictionary[Vector2i,Vector2i]
		var end_pos = t.health._get_tile_pos()
		came_from[start_pos] = start_pos
		var cost_so_far : Dictionary[Vector2i,int]
		cost_so_far[start_pos] = t.cost
		var routes = PriorityQueue.new(Compare)
		routes.push(PathData.new(start_pos,0))
		
		var found = false
		var loops = 0
		var max_loops = 1000
		while !routes.is_empty() and loops < max_loops:
			var current = routes.pop()
			if (t.health.global_position - _get_global_pos(current.pos)).length() <= get_range_to_target(t.health):
				end_pos = current.pos
				found = true
				break
			for nb in tile_neighbors:
				var nb_pos = current.pos + nb
				if !_has_tile_at_pos(nb_pos): continue
				if nb_pos != end_pos and tile_map.tile_buildings.has(nb_pos) and tile_map.tile_buildings[nb_pos] != null and tile_map.tile_buildings[nb_pos] != t.health: continue
				var newCost = cost_so_far[current.pos] + 1
				if !cost_so_far.has(nb_pos) or newCost < cost_so_far[nb_pos]:
					cost_so_far[nb_pos] = newCost
					routes.push(PathData.new(nb_pos,newCost + GetHeuristic(nb_pos,end_pos)))
					came_from[nb_pos] = current.pos
			loops += 1
		if !found:
			continue
		var current_cost = cost_so_far[end_pos]
		if current_cost >= best_cost: continue
		best_cost = current_cost
		var current_pos = end_pos
		best_path.clear()
		while current_pos != start_pos:
			best_path.append(_get_global_pos(current_pos))
			current_pos = came_from[current_pos]
		best_path.reverse()
		target = t.health
	_current_path = best_path
	
class Target:
	var health : Health
	var cost : int
	func _init(h,c):
		health = h
		cost = c
class PathData:
	var pos : Vector2i
	var cost : int
	func _init(p,c):
		pos = p
		cost = c
func Compare(data1 : PathData, data2 : PathData):
	return data1.cost > data2.cost
	
func GetHeuristic(data1 : Vector2i, data2 : Vector2i):
	return abs(data1.x - data2.x) + abs(data1.y - data2.y)

#endregion Pathfinding
