@abstract class_name Health extends Node

var _health : int = 0
var _maximum_health : int = 0

func init_health(max_health):
	_maximum_health = max_health
	_health = max_health
		
func hurt(damage) -> bool:
	_health -= damage
	if _health <= 0:
		kill()
		return true
	return false
		
@abstract func kill()
