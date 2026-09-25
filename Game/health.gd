@abstract class_name Health extends Node2D

var _health : int = 0
var _maximum_health : int = 0

var target : Health
var tile_map : GameTileMap

func init_health(max_health):
	_maximum_health = max_health
	_health = max_health
	tile_map = get_node("/root/Root/Ground/Map")
	tile_map.all_targettable.append(self)
		
func hurt(damage : int):
	_health -= damage
	if _health <= 0:
		on_kill()
		
func on_kill():
	var index = tile_map.all_targettable.find(self)
	if index > -1:
		tile_map.all_targettable.remove_at(index)
	kill()

func kill():
	pass
	
func _get_tile_pos() -> Vector2i:
	var local_pos = global_position - tile_map.global_position
	return tile_map.local_to_map(local_pos)
	
func can_target(possible : Health) -> bool:
	return true
