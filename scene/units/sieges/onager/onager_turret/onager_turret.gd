extends SiegeTurret

onready var _audio = $AudioStreamPlayer3D
onready var _animation = $AnimationPlayer

func _fire_at(direction : Vector3):
	._fire_at(direction)
	
	var boulders_count = int(rand_range(1,3))
	for i in boulders_count:
		var arrow = preload("res://scene/projectile/boulder/boulder.tscn").instance()
		arrow.sprite = ""
		arrow.player = player
		arrow.attack_damage = attack_damage
		arrow.team = team
		arrow.color = color
		arrow.is_master = is_master
		arrow.spread = 1.6
		parent.add_child(arrow)
		arrow.parent = parent
		arrow.translation = global_transform.origin
		arrow.launch(direction)
	
	_animation.play("firing")
	
	_audio.stream = preload("res://assets/sound/arrow_fly.wav")
	_audio.play()
