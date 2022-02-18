extends Spatial

signal target_align(_target)

onready var _animation = $AnimationPlayer
onready var _delay = $firing_delay

var delay = 1.2

func _ready():
	_delay.wait_time = 1.2

var target : Vector3 = Vector3.ZERO setget _set_target
func _set_target(v : Vector3):
	target = v
	_delay.start()
	set_process(true)

func shot():
	_animation.play("firing")
	
func stop():
	_animation.play("stop")
	
func _process(delta):
	if is_aiming_align() and _delay.is_stopped():
		emit_signal("target_align", target)
		set_process(false)
		return
		
	turn_facing_to(target, delta)
	
func turn_facing_to(target, delta):
	var alignment = get_target_alignment(target, global_transform.origin.y)
	global_transform = global_transform.interpolate_with(alignment, 2.5 * delta)

func get_target_alignment(target : Vector3, elevation : float) -> Transform:
	return global_transform.looking_at(Vector3(target.x, elevation, target.z), Vector3(0,1,0))

func is_aiming_align() -> bool:
	var alignment_basis_z = get_target_alignment(target, global_transform.origin.y).basis.z.z
	if Utils.compare_floats(alignment_basis_z, global_transform.basis.z.z):
		return true
		
	return false








