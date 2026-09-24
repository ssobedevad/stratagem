class_name Projectile extends Node2D

var _damage : int

func hit(target: Health):
	target.hurt(_damage)
	on_hit(target)

func on_hit(target: Health):
	pass
