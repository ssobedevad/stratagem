extends Unit

@export var arrow_obj : PackedScene

func attack():
	var bullet_inst = arrow_obj.instantiate()
	bullet_inst._damage = _attack_damage
	bullet_inst.target = target
	add_child(bullet_inst)
	bullet_inst.global_position = global_position

func get_unit_name() -> String:
	return "Archer"

func get_description() -> String:
	return "Low health and dps.\nLong range and moderate speed."

func get_cost() -> int:
	return 150

func get_unit_id() -> int:
	return 1
