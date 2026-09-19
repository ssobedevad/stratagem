@abstract class_name Unit extends Health

@export var _max_health : int
@export var _hitbox : CollisionShape2D

func _ready():
	init_health(_max_health)
