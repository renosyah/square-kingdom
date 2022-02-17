extends Node
class_name Buildings

const TYPE_CASTLE = "CASTLE"
const TYPE_FARM = "FARM"
const TYPE_TOWER= "TOWER"
const TYPE_UNIT_BUFF = "TYPE_UNIT_BUFF"

const BUILDINGS = [
	{
		id = "b-1",
		type_building = TYPE_CASTLE,
		name = "Castle",
		node_name = "",
		scene = "res://scene/buildings/castle/castle.tscn",
		attack_damage = 2.5,
		range_attack = 25.0,
		garrison_units = [1.2, 1.8, 1.4, 1.1],
		cp = 100.0,
		max_cp = 100.0,
		cp_regen_rate = 12.0,
		amount = 10,
		coin_produce_cooldown = 5,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO
	},
	{
		id = "b-2",
		type_building = TYPE_FARM,
		name = "Farm",
		node_name = "",
		scene = "res://scene/buildings/farm/farm.tscn",
		cp = 45.0,
		max_cp = 45.0,
		cp_regen_rate = 4.0,
		amount = 10,
		coin_produce_cooldown = 5,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO
	},
	{
		id = "b-3",
		type_building = TYPE_TOWER,
		name = "Tower",
		node_name = "",
		scene = "res://scene/buildings/tower/tower.tscn",
		attack_damage = 0.5,
		range_attack = 15.0,
		garrison_units = [1.2, 1.8, 1.4, 1.1],
		cp = 75.0,
		max_cp = 75.0,
		cp_regen_rate = 8.0,
		amount = 0,
		coin_produce_cooldown = 5,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO
	},
	{
		id = "b-4",
		type_building = TYPE_UNIT_BUFF,
		name = "Training Field",
		node_name = "",
		scene = "res://scene/buildings/training_field/training_field.tscn",
		cp = 75.0,
		max_cp = 75.0,
		cp_regen_rate = 8.0,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO
	}
]
