class_name Projectile extends Node2D

@export var _damage : int

func hit(target: Health):
	target.hurt(_damage)
	on_hit(target)

func on_hit(target: Health):
	pass
