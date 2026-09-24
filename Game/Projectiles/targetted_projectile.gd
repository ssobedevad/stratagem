class_name TargettedProjectile extends Projectile

@export var _move_speed : float
@export var _hit_radius : float
@export var _rotate_to_direction : bool
@export var _rotation_offset : float

var target : Health

func _physics_process(delta: float) -> void:
	if(target == null):
		queue_free()
		return
	var dist = (target.global_position - global_position).length()
	var direction = (target.global_position - global_position).normalized()
	if _rotate_to_direction:
		var desired_angle = direction.angle() + _rotation_offset
		rotation = desired_angle
	if dist <= _hit_radius:
		hit(target)
		queue_free()
		return
	global_position += direction * delta * _move_speed
