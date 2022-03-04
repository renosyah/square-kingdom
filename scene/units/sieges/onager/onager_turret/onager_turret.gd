extends "res://scene/units/sieges/balista/balista_bow/balista_bow.gd"

############################################################
# multiplayer func
remotesync func _sync_fire_at(direction : Vector3):
	#._sync_fire_at(direction : Vector3)
	var boulders_count = int(rand_range(3,6))
	for i in boulders_count:
		var arrow = preload("res://scene/projectile/boulder/boulder.tscn").instance()
		arrow.sprite = "res://scene/projectile/boulder/boulder.png"
		arrow.player = player
		arrow.attack_damage = attack_damage
		arrow.team = team
		arrow.color = color
		arrow.is_master = is_master
		arrow.spread = 1.3
		parent.add_child(arrow)
		arrow.parent = parent
		arrow.translation = global_transform.origin
		arrow.launch(direction)
	
	_animation.play("firing")
	
	_audio.stream = preload("res://assets/sound/arrow_fly.wav")
	_audio.play()
	
############################################################
