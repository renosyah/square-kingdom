extends "res://scene/units/sieges/ram/ram.gd"

var _tower
var _tower_data = {}

func set_data(_data):
	.set_data(_data)
	_tower_data = {
		id = "b-3",
		type_building = "TOWER",
		name = "Tower",
		node_name = "tower",
		scene = "res://scene/buildings/tower/tower.tscn",
		attack_damage = attack_damage,
		range_attack = range_attack + 5.0,
		garrison_units = [1.2, 1.8, 1.4, 1.1],
		cp = 75.0,
		max_cp = 75.0,
		cp_regen_rate = 8.0,
		amount = 0,
		coin_produce_cooldown = 5,
		team = team,
		color = color,
		translation = Vector3.ZERO
	}
	
func init_siege():
	# we override this shit!
	#.init_siege()
	if not _tower:
		_tower = load(_tower_data.scene).instance()
		_tower.player = player
		_tower.name = _tower_data.node_name
		_tower.set_network_master(get_network_master())
		_tower.set_data(_tower_data)
		_tower.can_be_capture = false
		_tower.translation = $pivot/tower_pos.translation
		$pivot.add_child(_tower)
		_tower.parent = self
		_tower.show_flag(false)
		
		if is_master():
			_tower.get_spotting_system_node().translation = Vector3.ZERO
		
		if is_instance_valid(target):
			_tower.set_target(target.get_path())
		
	_wheels = [$pivot/wheel_1, $pivot/wheel_2, $pivot/wheel_3, $pivot/wheel_4, $pivot/wheel_5, $pivot/wheel_6]
	$pivot/flag.set_flag_color(color)
	
func set_target(_target : NodePath):
	.set_target(_target)
	if not is_master():
		return
		
	if is_instance_valid(_tower):
		_tower.set_target(_target)
		
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
		
	if is_instance_valid(_tower):
		_tower.set_target(target.get_path())
	
func _on_VisibilityNotifier_screen_entered():
	visible = true
	
func _on_VisibilityNotifier_screen_exited():
	visible = false
