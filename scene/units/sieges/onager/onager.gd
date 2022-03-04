extends "res://scene/units/sieges/balista/balista.gd"

func init_siege():
	# we override this shit!
	#.init_siege()
	_turret_pos = $pivot/turret_pos
	_wheels = [$pivot/wheel_1, $pivot/wheel_2, $pivot/wheel_3, $pivot/wheel_4]
	_flag = $pivot/flag
	
	if not _turret:
		_turret = preload("res://scene/units/sieges/onager/onager_turret/onager_turret.tscn").instance()
		_turret.player = player
		_turret.attack_damage = attack_damage
		_turret.range_attack = range_attack + 5.0
		_turret.delay = attack_cooldown
		_turret.team = team
		_turret.color = color
		_turret.is_master = is_master()
		_turret.translation = _turret_pos.translation
		_turret.rotate_y(_turret_pos.rotation_degrees.y)
		_pivot.add_child(_turret)
		_turret.parent = self
		
		if is_instance_valid(target):
			_turret.set_target(target)
		
	_flag.set_flag_color(color)
