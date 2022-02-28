extends Spatial

signal target_align(_target)

onready var _audio = $AudioStreamPlayer3D
onready var _animation = $AnimationPlayer
onready var _firing_delay = $firing_delay

# attack
var player = {}
var target = null

# attr
var attack_damage = 1.0
var range_attack = 15.0

# tag
var team = ""
var color = Color.white

# misc
var parent
var is_master = true
var delay = 2.0
	
func _ready():
	_firing_delay.wait_time = delay
	parent = self
	
func set_target(_target):
	target = _target
	set_process(true)
	
func _process(delta):
	if not target:
		set_process(false)
		return
		
	if is_instance_valid(target):
		if not target.is_targetable(team):
			target = null
			return
			
		if _is_aiming_align(target.global_transform.origin):
			var distance_to_target = global_transform.origin.distance_to(target.global_transform.origin)
			if  distance_to_target <= range_attack:
				if _firing_delay.is_stopped():
					_fire_at(target.global_transform.origin)
					_firing_delay.start()
			
		_turn_facing_to(target.global_transform.origin, delta)
	
func _fire_at(direction : Vector3):
	var arrow = preload("res://scene/projectile/balista/bolt.tscn").instance()
	arrow.sprite = "res://scene/projectile/balista/ram_weapon.png"
	arrow.player = player
	arrow.attack_damage = attack_damage
	arrow.team = team
	arrow.color = color
	arrow.is_master = is_master
	arrow.spread = 0.2
	add_child(arrow)
	arrow.parent = parent
	arrow.translation = global_transform.origin
	arrow.launch(direction)
	
	_animation.play("firing")
	
	_audio.stream = preload("res://assets/sound/arrow_fly.wav")
	_audio.play()
	
	
func _turn_facing_to(_target : Vector3, delta):
	var alignment = _get_target_alignment(_target, global_transform.origin.y)
	global_transform = global_transform.interpolate_with(alignment, 2.5 * delta)

func _get_target_alignment(_target : Vector3, elevation : float) -> Transform:
	return global_transform.looking_at(Vector3(_target.x, elevation, _target.z), Vector3(0,1,0))

func _is_aiming_align(_target : Vector3) -> bool:
	var alignment_basis_z = _get_target_alignment(_target, global_transform.origin.y).basis.z.z
	if Utils.compare_floats(alignment_basis_z, global_transform.basis.z.z):
		return true
		
	return false








