extends SiegeTurret

const ARROW_SOUND = [
	preload("res://assets/sound/stab1.wav"),
	preload("res://assets/sound/stab2.wav")
]

onready var _shoting_pos = $shoting_pos
onready var _audio = $AudioStreamPlayer3D

# target
var garrison_units = []
var _garrison = []

func _ready():
	for i in garrison_units:
		var _cooldown_timmer = Timer.new()
		_cooldown_timmer.wait_time = i
		_cooldown_timmer.autostart = false
		_cooldown_timmer.one_shot = true
		
		var _sound = _audio.duplicate()

		_garrison.append({ 
			cooldown_timmer = _cooldown_timmer,
			sound = _sound
		})
		add_child(_sound)
		add_child(_cooldown_timmer)
	
func moving_turret(delta):
	# we override this shit
	# moving_turret(delta)
	if not target:
		set_process(false)
		return
		
	if is_instance_valid(target):
		if not target.is_targetable(team):
			target = null
			return
			
		var distance_to_target = global_transform.origin.distance_to(target.global_transform.origin)
		if  distance_to_target <= range_attack:
			for i in _garrison:
				if i.cooldown_timmer.is_stopped():
					_fire_at(target.global_transform.origin)
					if not i.sound.playing:
						i.sound.stream = ARROW_SOUND[randi() % ARROW_SOUND.size()]
						i.sound.play()
						
					i.cooldown_timmer.start()
	
func _on_iddle_timer_timeout():
	# we override this shit!
	#._on_iddle_timer_timeout()
	pass

func _fire_at(direction : Vector3):
	._fire_at(direction)
	
	var arrow = preload("res://scene/projectile/arrow/arrow.tscn").instance()
	arrow.attack_damage = attack_damage
	arrow.team = team
	arrow.color = color
	arrow.player = player
	arrow.is_master = is_master
	parent.add_child(arrow)
	arrow.parent = parent
	arrow.translation = _shoting_pos.global_transform.origin
	arrow.spread = 1.8
	arrow.launch(direction)








