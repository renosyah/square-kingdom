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
var rotation_speed = 2.5

# tag
var team = ""
var color = Color.white

# misc
var parent
var is_master = true

# timer
onready var _tween = Tween.new()
onready var _firing_delay = Timer.new()
onready var _iddle_timer = Timer.new()
onready var _blank_spatial = Spatial.new()


func _ready():
	_firing_delay.wait_time = delay
	_firing_delay.autostart = false
	_firing_delay.one_shot = true
	add_child(_firing_delay)
		
	_iddle_timer.wait_time = 2.0
	_iddle_timer.autostart = true
	_iddle_timer.connect("timeout", self, "_on_iddle_timer_timeout")
	add_child(_iddle_timer)
		
	add_child(_tween)
	get_parent().add_child(_blank_spatial)
	_blank_spatial.global_transform.origin = global_transform.origin
	
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
	
func _on_iddle_timer_timeout():
	if is_instance_valid(target):
		return
		
	_tween.interpolate_property(self,"rotation_degrees:y", rotation_degrees.y, rand_range(-180,180), 1.5)
	_tween.start()
	
func _turn_facing_to(_target : Vector3, delta):
	var alignment = _get_target_alignment(_target, global_transform.origin.y)
	global_transform = global_transform.interpolate_with(alignment, rotation_speed * delta)
	
func _get_target_alignment(_target : Vector3, elevation : float) -> Transform:
	return global_transform.looking_at(Vector3(_target.x, elevation, _target.z), Vector3(0,1,0))

func _is_aiming_align(_target : Vector3) -> bool:
	_blank_spatial.look_at(Vector3(_target.x, global_transform.origin.y, _target.z), Vector3(0,1,0))
	return Utils.compare_floats(rotation_degrees.y, _blank_spatial.rotation_degrees.y, 5.0)
	
	
	
	
	
	
	
	
	









