extends Unit

func attack():
	target.hurt(_attack_damage)

func get_unit_name() -> String:
	return "Thief"

func get_description() -> String:
	return "Low health and high dps.\nMelee range and high speed."

func get_cost() -> int:
	return 150

func get_unit_id() -> int:
	return 2
