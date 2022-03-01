extends "res://scene/units/sieges/ram/ram.gd"

var _turret

############################################################
# multiplayer func
remotesync func _set_target(_target : NodePath):
	var _target_node = get_node_or_null(_target)
	if not is_instance_valid(_target_node):
		return
	
	if is_instance_valid(_turret):
		_turret.set_target(_target_node)
		
remotesync func _take_damage(_damage : float, _hit_by: Dictionary):
	._take_damage(_damage, _hit_by)
	
	if is_dead:
		return
		
	_set_target(_hit_by.node_path)
	
remotesync func _dead():
	._dead()
	if is_instance_valid(_turret):
		_turret.is_dead = true
	
############################################################
func init_siege():
	# we override this shit!
	#.init_siege()
	if not _turret:
		_turret = preload("res://scene/units/sieges/balista/balista_bow/balista_bow.tscn").instance()
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
		
		if is_instance_valid(target):
			_turret.set_target(target)

	_wheels = [$pivot/wheel_1, $pivot/wheel_2, $pivot/wheel_3, $pivot/wheel_4]
	$pivot/flag.set_flag_color(color)
	
func set_target(_target : NodePath):
	.set_target(_target)
	if not is_master():
		return
		
	rpc("_set_target", _target)
	
func _on_spotted(body):
	._on_spotted(body)
	if not is_master():
		return
		
	rpc("_set_target", body.get_path())
	
func perform_attack():
	# we override this shit!
	#.perform_attack()
	
	if not is_master():
		return
		
	if target is Building:
		target.capture(
			capture_damage, 
			Utils.create_hit_by(player, self.get_path(), team, color)
		)
		
	
func _on_VisibilityNotifier_screen_entered():
	visible = true
	
func _on_VisibilityNotifier_screen_exited():
	visible = false
