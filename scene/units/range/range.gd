extends "res://scene/units/melee/melee.gd"

var projectile_scene = ""

############################################################
# multiplayer func
remotesync func _shot_at(target_translation : Vector3):
	var arrow = load(projectile_scene).instance()
	arrow.attack_damage = attack_damage
	arrow.team = team
	arrow.color = color
	arrow.is_master = is_master()
	add_child(arrow)
	arrow.translation = translation
	arrow.translation.y += 2
	arrow.launch(target_translation)
	
	._perform_attack()

############################################################
func set_data(_data):
	.set_data(_data)
	projectile_scene = _data.projectile_scene
	
func perform_attack():
	#.perform_attack()
	
	if not is_master():
		return
		
	if target is Building:
		target.capture(capture_damage, {node_path = self.get_path(), team = team, color = color})
		
	rpc("_shot_at", target.translation)




