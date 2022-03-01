extends "res://scene/units/sieges/balista/balista.gd"

func init_siege():
	# we override this shit!
	#.init_siege()
	if not _turret:
		_turret = preload("res://scene/units/sieges/howitzer/howitzer_turret/howitzer_turret.tscn").instance()
		_turret.player = player
		_turret.attack_damage = attack_damage
		_turret.range_attack = range_attack + 5.0
		_turret.team = team
		_turret.color = color
		_turret.is_master = is_master()
		_turret.delay = attack_cooldown
		_turret.translation = $pivot/turret_pos.translation
		_turret.rotate_y($pivot/turret_pos.rotation_degrees.y)
		$pivot.add_child(_turret)
		_turret.parent = self
		
	_wheels = [$pivot/wheel_1, $pivot/wheel_2, $pivot/wheel_3, $pivot/wheel_4,$pivot/wheel_5, $pivot/wheel_6]
	$pivot/flag.set_flag_color(color)
