extends Spatial
class_name SiegeTurret

var is_dead = false

# attack
var player = {}
var target = null
var delay = 2.0

# attr
var attack_damage = 1.0
var range_attack = 15.0

# tag
var team = ""
var color = Color.white

# misc
var parent
var is_master = true

# timer
var _firing_delay

func _ready():
	if not  _firing_delay:
		_firing_delay = Timer.new()
		_firing_delay.wait_time = delay
		_firing_delay.autostart = false
		_firing_delay.one_shot = true
		add_child(_firing_delay)
		
	parent = self
	set_process(false)
	
func set_target(_target):
	target = _target
	set_process(true)
	
func _process(delta):
	if is_dead:
		set_process(false)
		return
	
	moving_turret(delta)
	
func moving_turret(delta):
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
	pass
	
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
