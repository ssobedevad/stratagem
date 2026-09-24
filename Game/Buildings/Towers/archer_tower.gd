extends Tower

@export var arrow_obj : PackedScene

func get_building_name() -> String:
	return "Archer Tower"

func get_description() -> String:
	return "Shoots low damage projectiles at a moderate rate.\nHigh range and low health."

func get_cost() -> int:
	return 125

func get_building_id() -> int:
	return 51
	
func attack():
	var arrow_inst = arrow_obj.instantiate()
	arrow_inst._damage = _damage
	arrow_inst.target = target
	add_child(arrow_inst)
	arrow_inst.global_position = global_position

func _physics_process(delta: float) -> void:
	if !placed: return
	if target == null :
		_attack_timer = 0
		get_target()
	else:
		var distance_to_target = (target.global_position - global_position).length()
		if distance_to_target > _range_pixels():
			target = null
			return
		var direction_to_target = (target.global_position - global_position).normalized()
		var desired_angle = direction_to_target.angle() + PI/4
		_gun.rotation = desired_angle
		_attack_timer += delta
		if (_attack_timer >= _attack_time):
			_attack_timer -= _attack_time
			attack()
