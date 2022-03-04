extends SiegeTurret

onready var _audio = $AudioStreamPlayer3D
onready var _animation = $AnimationPlayer

############################################################
# multiplayer func
remotesync func _sync_fire_at(direction : Vector3):
	var arrow = preload("res://scene/projectile/balista/bolt.tscn").instance()
	arrow.sprite = "res://scene/projectile/balista/ram_weapon.png"
	arrow.player = player
	arrow.attack_damage = attack_damage
	arrow.team = team
	arrow.color = color
	arrow.is_master = is_master
	arrow.spread = 0.2
	parent.add_child(arrow)
	arrow.parent = parent
	arrow.translation = global_transform.origin
	arrow.launch(direction)
	
	_animation.play("firing")
	
	_audio.stream = preload("res://assets/sound/arrow_fly.wav")
	_audio.play()
	
############################################################
func _fire_at(direction : Vector3):
	._fire_at(direction)
	
	if is_master:
		rpc_unreliable("_sync_fire_at", direction)





