extends "res://scene/units/sieges/balista/balista_bow/balista_bow.gd"

############################################################
# multiplayer func
remotesync func _sync_fire_at(direction : Vector3):
	#._sync_fire_at(direction : Vector3)
	var arrow = preload("res://scene/projectile/boulder/boulder.tscn").instance()
	arrow.sprite = "res://scene/projectile/boulder/boulder.png"
	arrow.player = player
	arrow.attack_damage = attack_damage
	arrow.team = team
	arrow.color = color
	arrow.is_master = is_master
	arrow.spread = 1.1
	parent.add_child(arrow)
	arrow.parent = parent
	arrow.translation = $shot_pos.global_transform.origin
	arrow.launch(direction)
	
	_animation.play("firing")
	
	_audio.stream = preload("res://assets/sound/heavy_cannon.wav")
	_audio.play()
############################################################






