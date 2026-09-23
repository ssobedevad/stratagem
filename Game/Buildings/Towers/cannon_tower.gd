extends Tower

@export var bullet_obj : PackedScene
@export var fire_pos : Marker2D

func get_building_name() -> String:
	return "Cannon Tower"

func get_description() -> String:
	return "Shoots high damage projectiles at a moderate rate.\nLow range and moderate health."

func get_cost() -> int:
	return 100

func get_building_id() -> int:
	return 50
	
func attack():
	var bullet_inst = bullet_obj.instantiate()
	bullet_inst.target = target
	add_child(bullet_inst)
	bullet_inst.global_position = fire_pos.global_position

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
		var desired_angle = direction_to_target.angle() + PI/2
		_gun.rotation = desired_angle
		_attack_timer += delta
		if (_attack_timer >= _attack_time):
			_attack_timer -= _attack_time
			attack()
