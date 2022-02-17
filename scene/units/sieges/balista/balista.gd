extends "res://scene/units/sieges/ram/ram.gd"

var _balista_bow
var projectile_scene = ""

############################################################
# multiplayer func
remotesync func _shot_at(target_translation : Vector3):
	var arrow = load(projectile_scene).instance()
	arrow.attack_damage = attack_damage
	arrow.team = team
	arrow.color = color
	arrow.sprite = "res://scene/projectile/balista/ram_weapon.png"
	arrow.is_master = is_master()
	arrow.spread = 0.2
	add_child(arrow)
	arrow.translation = translation
	arrow.launch(target_translation)
	
	_balista_bow.shot()
	_balista_bow.target = target_translation
	
	_audio.stream = preload("res://assets/sound/arrow_fly.wav")
	_audio.play()
	
remotesync func _set_walking_state(_val : bool):
	._set_walking_state(_val)
	if is_walking:
		_balista_bow.target = Vector3.ZERO
		
############################################################
func set_data(_data):
	.set_data(_data)
	projectile_scene = _data.projectile_scene
	
func init_siege():
	_balista_bow = $pivot/balista_bow
	_balista_bow.set_network_master(get_network_master())
	
	_wheels = [$pivot/wheel_1, $pivot/wheel_2, $pivot/wheel_3, $pivot/wheel_4]
	$pivot/flag.set_flag_color(color)
	

func perform_attack():
	# we override this shit!
	#.perform_attack()
	
	if not is_master():
		return
		
	if target is Building:
		target.capture(capture_damage, {node_path = self.get_path(), team = team, color = color})
		
	rpc("_shot_at", target.translation)
	
	
func _on_VisibilityNotifier_screen_entered():
	visible = true
	
func _on_VisibilityNotifier_screen_exited():
	visible = false
