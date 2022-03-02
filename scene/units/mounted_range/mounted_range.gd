extends "res://scene/units/mounted_melee/mounted_melee.gd"

onready var _shot_delay = $shot_delay
var projectile_scene = ""

############################################################
# multiplayer func
# to control what puppet targetting
remotesync func _set_target(_target : NodePath):
	if is_master():
		return
		
	var _target_node = get_node_or_null(_target)
	if not is_instance_valid(_target_node):
		return
	
	target = _target_node
		
remotesync func _take_damage(_damage : float, _hit_by: Dictionary):
	._take_damage(_damage, _hit_by)
	if is_dead:
		return
		
	if is_master():
		return
		
	_set_target(_hit_by.node_path)
	
############################################################
func set_data(_data):
	.set_data(_data)
	projectile_scene = _data.projectile_scene
	
func _ready():
	_shot_delay.wait_time = attack_cooldown
	set_process(true)
	
func perform_attack():
	#.perform_attack()
	
	if not is_master():
		return
		
	if target is Building:
		target.capture(
			capture_damage,
			Utils.create_hit_by(player, self.get_path(), team, color)
		)
		
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
	
func moving(delta):
	.moving(delta)
	
	if is_dead:
		return
		
	if not target:
		return
		
	if not is_instance_valid(target):
		return
		
	if not target.is_targetable(team):
		return
		
	var distance_to_target = translation.distance_to(target.translation)
	if distance_to_target <= range_attack + 5.0:
		if _shot_delay.is_stopped():
			_fire()
			_shot_delay.start()
		
func _fire():
	var arrow = load(projectile_scene).instance()
	arrow.attack_damage = attack_damage
	arrow.team = team
	arrow.color = color
	arrow.player = player
	arrow.is_master = is_master()
	arrow.spread = 0.4
	add_child(arrow)
	arrow.translation = translation
	arrow.translation.y += 2
	arrow.launch(target.translation)
	
	._perform_attack()


