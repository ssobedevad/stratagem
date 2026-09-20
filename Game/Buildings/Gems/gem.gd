extends Building

func _clicked(viewport: Viewport, event: InputEvent, shape_idx: int):
	pass

func get_building_name() -> String:
	return "Large Gem"

func get_description() -> String:
	return "The centerpiece of any base.\nWhen destroyed, the attacker wins."

func get_cost() -> int:
	return 100
	
func get_building_id() -> int:
	return 0
