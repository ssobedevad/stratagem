extends Unit

func attack():
	target.hurt(_attack_damage)

func get_unit_name() -> String:
	return "Swordsman"

func get_description() -> String:
	return "Moderate health and dps.\nMelee range and moderate speed."

func get_cost() -> int:
	return 100

func get_unit_id() -> int:
	return 0
