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
	add_child(arrow)
	arrow.translation = translation
	arrow.translation.y += 2
	arrow.launch(target_translation)
	
	_balista_bow.shot()
	_audio.stream = preload("res://assets/sound/arrow_fly.wav")
	_audio.play()
	
############################################################
func set_data(_data):
	.set_data(_data)
	projectile_scene = _data.projectile_scene
	
func init_siege():
	_balista_bow = $pivot/balista_bow
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
