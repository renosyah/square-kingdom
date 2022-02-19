extends Node
class_name Units

const TYPE_UNIT_MELEE = "MELEE"
const TYPE_UNIT_RANGE = "RANGE"

const UNITS = [
	# melee sword
	{
		id = "u-1",
		type_unit = TYPE_UNIT_MELEE,
		name = "Militia",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_empty.png",
		cooldown = 6.0,
		cost = 15,
		node_name = "",
		scene = "res://scene/units/melee/melee.tscn",
		primary_weapon_scene = "res://scene/weapon/melee/sword/sword.tscn",
		secondary_weapon_scene = "",
		helm = "",
		armor = "res://scene/units/uniform/armor_0.png",
		hp = 10.0,
		max_hp = 10.0,
		speed = 4.0,
		attack_damage = 4.0,
		capture_damage = 5.0,
		attack_cooldown = 1.2,
		range_attack = 1.4,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	{
		id = "u-2",
		type_unit = TYPE_UNIT_MELEE,
		name = "Man at arms",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_man_at_arms.png",
		cooldown = 8.0,
		cost = 20,
		node_name = "",
		scene = "res://scene/units/melee/melee.tscn",
		primary_weapon_scene = "res://scene/weapon/melee/sword/sword.tscn",
		secondary_weapon_scene = "res://scene/weapon/shield/wooden_shield/shield.tscn",
		helm = "res://scene/units/uniform/helm_1.png",
		armor = "res://scene/units/uniform/armor_1.png",
		hp = 15.0,
		max_hp = 15.0,
		speed = 3.5,
		attack_damage = 5.0,
		capture_damage = 5.0,
		attack_cooldown = 1.4,
		range_attack = 1.4,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	{
		id = "u-3",
		type_unit = TYPE_UNIT_MELEE,
		name = "Swordman",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_swordman.png",
		cooldown = 12.0,
		cost = 25,
		node_name = "",
		scene = "res://scene/units/melee/melee.tscn",
		primary_weapon_scene = "res://scene/weapon/melee/sword/sword.tscn",
		secondary_weapon_scene = "res://scene/weapon/shield/iron_shield/iron_shield.tscn",
		helm = "res://scene/units/uniform/helm_2.png",
		armor = "res://scene/units/uniform/armor_2.png",
		hp = 25.0,
		max_hp = 25.0,
		speed = 3.2,
		attack_damage = 8.0,
		capture_damage = 5.0,
		attack_cooldown = 1.2,
		range_attack = 1.6,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	# mounted melee
	{
		id = "cav-u-1",
		type_unit = TYPE_UNIT_MELEE,
		name = "Light Cavalry",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_scout_cavalry.png",
		cooldown = 9.5,
		cost = 20,
		node_name = "",
		scene = "res://scene/units/mounted_melee/mounted_melee.tscn",
		primary_weapon_scene = "res://scene/weapon/melee/sword/sword.tscn",
		secondary_weapon_scene = "res://scene/weapon/shield/round_wooden_shield/round_wooden_shield.tscn",
		helm = "res://scene/units/uniform/helm_1.png",
		armor = "res://scene/units/uniform/armor_1.png",
		mount_scene = "res://scene/mount/light_horse/horse.tscn",
		hp = 35.0,
		max_hp = 35.0,
		speed = 6.5,
		attack_damage = 5.0,
		capture_damage = 5.0,
		attack_cooldown = 1.4,
		range_attack = 1.4,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	{
		id = "cav-u-2",
		type_unit = TYPE_UNIT_MELEE,
		name = "Spear Cavalry",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_light_cavalry.png",
		cooldown = 8.5,
		cost = 25,
		node_name = "",
		scene = "res://scene/units/mounted_melee/mounted_melee.tscn",
		primary_weapon_scene = "res://scene/weapon/melee/spear/spear.tscn",
		secondary_weapon_scene = "res://scene/weapon/shield/round_wooden_shield/round_wooden_shield.tscn",
		helm = "res://scene/units/uniform/helm_1.png",
		armor = "res://scene/units/uniform/armor_1.png",
		mount_scene = "res://scene/mount/light_horse/horse.tscn",
		hp = 40.0,
		max_hp = 40.0,
		speed = 6.5,
		attack_damage = 7.0,
		capture_damage = 5.0,
		attack_cooldown = 1.5,
		range_attack = 1.8,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	{
		id = "cav-u-3",
		type_unit = TYPE_UNIT_MELEE,
		name = "Knight",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_heavy_cavalry.png",
		cooldown = 10.0,
		cost = 35,
		node_name = "",
		scene = "res://scene/units/mounted_melee/mounted_melee.tscn",
		primary_weapon_scene = "res://scene/weapon/melee/sword/sword.tscn",
		secondary_weapon_scene = "res://scene/weapon/shield/iron_shield/iron_shield.tscn",
		helm = "res://scene/units/uniform/helm_2.png",
		armor = "res://scene/units/uniform/armor_2.png",
		mount_scene = "res://scene/mount/armored_horse/horse.tscn",
		hp = 60.0,
		max_hp = 60.0,
		speed = 5.5,
		attack_damage = 9.0,
		capture_damage = 5.0,
		attack_cooldown = 1.9,
		range_attack = 1.6,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	{
		id = "cav-u-3",
		type_unit = TYPE_UNIT_MELEE,
		name = "Cavalier",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_cavalier.png",
		cooldown = 10.0,
		cost = 30,
		node_name = "",
		scene = "res://scene/units/mounted_melee/mounted_melee.tscn",
		primary_weapon_scene = "res://scene/weapon/melee/spear/spear.tscn",
		secondary_weapon_scene = "res://scene/weapon/shield/iron_shield/iron_shield.tscn",
		helm = "res://scene/units/uniform/helm_2.png",
		armor = "res://scene/units/uniform/armor_2.png",
		mount_scene = "res://scene/mount/armored_horse/horse.tscn",
		hp = 55.0,
		max_hp = 55.0,
		speed = 5.5,
		attack_damage = 8.0,
		capture_damage = 5.0,
		attack_cooldown = 1.9,
		range_attack = 1.8,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	# mounted range
	{
		id = "cav-u-4",
		type_unit = TYPE_UNIT_RANGE,
		name = "Archer Cavalry",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_archer_cavalry.png",
		cooldown = 9.5,
		cost = 25,
		node_name = "",
		scene = "res://scene/units/mounted_range/mounted_range.tscn",
		primary_weapon_scene = "res://scene/weapon/range/bow/bow.tscn",
		secondary_weapon_scene = "",
		projectile_scene = "res://scene/projectile/arrow/arrow.tscn",
		helm = "res://scene/units/uniform/helm_1.png",
		armor = "res://scene/units/uniform/armor_1.png",
		mount_scene = "res://scene/mount/light_horse/horse.tscn",
		hp = 30.0,
		max_hp = 30.0,
		speed = 6.5,
		attack_damage = 6.0,
		capture_damage = 3.0,
		attack_cooldown = 1.2,
		range_attack = 12.4,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	# melee spear
	{
		id = "u-4",
		type_unit = TYPE_UNIT_MELEE,
		name = "Spearman",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_spearman.png",
		cooldown = 7.0,
		cost = 10,
		node_name = "",
		scene = "res://scene/units/melee/melee.tscn",
		primary_weapon_scene = "res://scene/weapon/melee/spear/spear.tscn",
		helm = "res://scene/units/uniform/helm_0.png",
		armor = "res://scene/units/uniform/armor_0.png",
		secondary_weapon_scene = "",
		hp = 12.0,
		max_hp = 12.0,
		speed = 4.5,
		attack_damage = 7.0,
		capture_damage = 5.0,
		attack_cooldown = 1.4,
		range_attack = 2.4,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	{
		id = "u-5",
		type_unit = TYPE_UNIT_MELEE,
		name = "Pikeman",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_pikeman.png",
		cooldown = 9.5,
		cost = 15,
		node_name = "",
		scene = "res://scene/units/melee/melee.tscn",
		primary_weapon_scene = "res://scene/weapon/melee/pike/pike.tscn",
		secondary_weapon_scene = "",
		helm = "res://scene/units/uniform/helm_1.png",
		armor = "res://scene/units/uniform/armor_1.png",
		hp = 22.0,
		max_hp = 22.0,
		speed = 4.2,
		attack_damage = 8.0,
		capture_damage = 5.0,
		attack_cooldown = 1.4,
		range_attack = 2.4,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	{
		id = "u-6",
		type_unit = TYPE_UNIT_MELEE,
		name = "Halberdier",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_halberdier.png",
		cooldown = 14.5,
		cost = 35,
		node_name = "",
		scene = "res://scene/units/melee/melee.tscn",
		primary_weapon_scene = "res://scene/weapon/melee/pike/pike.tscn",
		secondary_weapon_scene = "res://scene/weapon/shield/iron_shield/iron_shield.tscn",
		helm = "res://scene/units/uniform/helm_2.png",
		armor = "res://scene/units/uniform/armor_2.png",
		hp = 28.0,
		max_hp = 28.0,
		speed = 3.2,
		attack_damage = 9.5,
		capture_damage = 5.0,
		attack_cooldown = 1.4,
		range_attack = 2.8,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	# range fletcher
	{
		id = "u-7",
		type_unit = TYPE_UNIT_RANGE,
		name = "Archer",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_archer_militia.png",
		cooldown = 8.5,
		cost = 10,
		node_name = "",
		scene = "res://scene/units/range/range.tscn",
		primary_weapon_scene = "res://scene/weapon/range/bow/bow.tscn",
		secondary_weapon_scene = "",
		projectile_scene = "res://scene/projectile/arrow/arrow.tscn",
		helm = "",
		armor = "res://scene/units/uniform/armor_0.png",
		hp = 12.0,
		max_hp = 12.0,
		speed = 4.1,
		attack_damage = 6.0,
		capture_damage = 3.0,
		attack_cooldown = 1.2,
		range_attack = 12.4,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	{
		id = "u-8",
		type_unit = TYPE_UNIT_RANGE,
		name = "Bowman",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_longbowman.png",
		cooldown = 14.0,
		cost = 15,
		node_name = "",
		scene = "res://scene/units/range/range.tscn",
		primary_weapon_scene = "res://scene/weapon/range/bow/bow.tscn",
		secondary_weapon_scene = "",
		projectile_scene = "res://scene/projectile/arrow/arrow.tscn",
		helm = "res://scene/units/uniform/helm_1.png",
		armor = "res://scene/units/uniform/armor_1.png",
		hp = 17.0,
		max_hp = 17.0,
		speed = 3.9,
		attack_damage = 4.0,
		capture_damage = 3.0,
		attack_cooldown = 1.2,
		range_attack = 14.4,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	{
		id = "u-9",
		type_unit = TYPE_UNIT_RANGE,
		name = "Crossbowman",
		icon = "res://assets/ui/icon/squad_icon/icon_squad_crossbowman.png",
		cooldown = 15.5,
		cost = 20,
		node_name = "",
		scene = "res://scene/units/range/range.tscn",
		primary_weapon_scene = "res://scene/weapon/range/crossbow/crossbow.tscn",
		secondary_weapon_scene = "",
		projectile_scene = "res://scene/projectile/arrow/arrow.tscn",
		helm = "res://scene/units/uniform/helm_1.png",
		armor = "res://scene/units/uniform/armor_1.png",
		hp = 18.0,
		max_hp = 18.0,
		speed = 3.1,
		attack_damage = 12.0,
		capture_damage = 3.0,
		attack_cooldown = 3.2,
		range_attack = 10.4,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	# siege engine
	{
		id = "u-10",
		type_unit = TYPE_UNIT_MELEE,
		name = "Batering Ram",
		icon = "res://assets/ui/icon/squad_icon/icon_battering_ram.png",
		cooldown = 15.0,
		cost = 40,
		node_name = "",
		scene = "res://scene/units/sieges/ram/ram.tscn",
		hp = 80.0,
		max_hp = 80.0,
		speed = 1.2,
		attack_damage = 12.0,
		capture_damage = 12.0,
		attack_cooldown = 2.8,
		range_attack = 2.8,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	{
		id = "u-11",
		type_unit = TYPE_UNIT_RANGE,
		name = "Balista",
		icon = "res://assets/ui/icon/squad_icon/icon_balista.png",
		cooldown = 17.0,
		cost = 50,
		node_name = "",
		scene = "res://scene/units/sieges/balista/balista.tscn",
		projectile_scene = "res://scene/projectile/balista/bolt.tscn",
		hp = 55.0,
		max_hp = 55.0,
		speed = 1.2,
		attack_damage = 16.0,
		capture_damage = 8.0,
		attack_cooldown = 2.7,
		range_attack = 22.0,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
	{
		id = "u-12",
		type_unit = TYPE_UNIT_RANGE,
		name = "Siege Tower",
		icon = "res://assets/ui/icon/squad_icon/icon_siege_tower.png",
		cooldown = 16.0,
		cost = 45,
		node_name = "",
		scene = "res://scene/units/sieges/siege_tower/siege_tower.tscn",
		hp = 70.0,
		max_hp = 70.0,
		speed = 1.5,
		attack_damage = 0.5,
		capture_damage = 8.0,
		attack_cooldown = 2.7,
		range_attack = 18.0,
		team = "",
		color = Color.white,
		translation = Vector3.ZERO,
		is_draw = false,
	},
]
