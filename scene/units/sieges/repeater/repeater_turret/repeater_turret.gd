extends SiegeTurret

const ARROW_SOUND = [
	preload("res://assets/sound/stab1.wav"),
	preload("res://assets/sound/stab2.wav")
]

onready var _audio = $AudioStreamPlayer3D
onready var _animation = $AnimationPlayer

func _fire_at(direction : Vector3):
	._fire_at(direction)
	
	var arrow = preload("res://scene/projectile/arrow/arrow.tscn").instance()
	arrow.sprite = "res://scene/projectile/arrow/arrow.png"
	arrow.player = player
	arrow.attack_damage = attack_damage
	arrow.team = team
	arrow.color = color
	arrow.is_master = is_master
	arrow.spread = 1.4
	add_child(arrow)
	arrow.parent = parent
	arrow.translation = $shot_pos.global_transform.origin
	arrow.launch(direction)
	
	_animation.play("firing")
	
	_audio.stream = ARROW_SOUND[randi() % ARROW_SOUND.size()]
	_audio.play()
