extends Building

# target
var target = null # other unit node

# turret
var platform_name = ""
var turret_data = {}

onready var _pivot = $pivot
onready var _turret_pos = $turret_pos
onready var _flag = $flag
onready var _tween = $Tween
onready var _cp_bar = $hpBar

# misc
var _turret
var _spotting
var _idle_timmer

############################################################
# multiplayer func
remotesync func _set_target(_target : NodePath):
	var _target_node = get_node_or_null(_target)
	if not is_instance_valid(_target_node):
		return
	
	if is_instance_valid(_turret):
		_turret.set_target(_target_node)
	
remotesync func _recapture(_cp_damage_restore : float):
	._recapture(_cp_damage_restore)
	_cp_bar.update_bar(cp, max_cp)
	_cp_bar.modulate.a = 1
	
remotesync func _finish_recaptured():
	._finish_recaptured()
	_flag.set_flag_color(color)
	_cp_bar.set_hp_bar_color(color)
	_cp_bar.update_bar(cp, max_cp)
	_cp_bar.modulate.a = 1
	_tween.interpolate_property(_cp_bar, "modulate:a", 1 , 0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
remotesync func _capture(_cp_damage : float, _capture_by: Dictionary):
	._capture(_cp_damage, _capture_by)
	_cp_bar.update_bar(cp, max_cp)
	_cp_bar.modulate.a = 1
	
	_set_target(_capture_by.node_path)
	
remotesync func _finish_captured(_capture_by: Dictionary):
	._finish_captured(_capture_by)
	_flag.set_flag_color(color)
	_cp_bar.set_hp_bar_color(color)
	_cp_bar.update_bar(cp, max_cp)
	_cp_bar.modulate.a = 1
	_tween.interpolate_property(_cp_bar, "modulate:a", 1 , 0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
	if is_instance_valid(_spotting):
		_spotting.team = team
		
	if is_instance_valid(_turret):
		_turret.player = player
		_turret.team = team
		_turret.color = color
	
############################################################
func set_data(_data):
	.set_data(_data)
	turret_data = _data.turret_data
	platform_name = turret_data["platform_name"]
	
func _ready():
	set_process(false)
	
	_flag.set_flag_color(color)
	_cp_bar.show_label(false)
	_cp_bar.set_hp_bar_color(color)
	_cp_bar.update_bar(cp,max_cp)
	_cp_bar.modulate.a = 0.0

	if not _turret:
		_turret = load(turret_data["turret_scene"]).instance()
		for i in turret_data.keys():
			if not _turret.get(i) == null:
				_turret[i] = turret_data[i]
				
		_turret.player = player
		_turret.team = team
		_turret.color = color
		_turret.is_master = is_master()
		_turret.translation = _turret_pos.translation
		_turret.rotate_y(_turret_pos.rotation_degrees.y)
		add_child(_turret)
		_turret.parent = self
		
		if is_instance_valid(target):
			_turret.set_target(target)
			
	if not .is_master():
		return
		
	if not _idle_timmer:
		_idle_timmer = Timer.new()
		_idle_timmer.wait_time = rand_range(2,4)
		_idle_timmer.connect("timeout", self , "_idle_timmer_timeout")
		_idle_timmer.autostart = true
		add_child(_idle_timmer)
		
	if not _spotting:
		_spotting = preload("res://assets/other/spotting-system/spotting_system.tscn").instance()
		add_child(_spotting)
		_spotting.enable = true
		_spotting.spotting_range = turret_data["range_attack"] - 5.0
		_spotting.add_exception(self)
		_spotting.team = team
		_spotting.connect("on_spotted", self,"_on_spotted")
		_spotting.translation = Vector3(0, 0.5, 0)
		
	emit_signal("on_ready", self)
	
	
func set_target(_target : NodePath):
	if not is_master():
		return
		
	rpc("_set_target", _target)
	
func _idle_timmer_timeout():
	if not is_master():
		return
		
	if not is_instance_valid(target):
		_spotting.team = team
		_spotting.enable = true
		return
		
	if not target.is_targetable(team):
		return
	
	_spotting.team = team
	_spotting.enable = true
	
	
func _on_spotted(body):
	if not is_master():
		return
		
	rpc("_set_target", body.get_path())
	
func _on_VisibilityNotifier_screen_entered():
	_pivot.visible = true
	
func _on_VisibilityNotifier_screen_exited():
	_pivot.visible = false
