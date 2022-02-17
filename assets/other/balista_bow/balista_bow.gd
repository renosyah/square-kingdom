extends Spatial

onready var _animation = $AnimationPlayer

var target : Vector3 = Vector3.ZERO setget _set_target
func _set_target(v : Vector3):
	target = v
	set_process(target != Vector3.ZERO)

func shot():
	_animation.play("firing")
	
func stop():
	_animation.play("firing")
	
func _process(delta):
	if target != Vector3.ZERO:
		turn_faccing_to(target, delta)
	else:
		set_process(false)
		
func turn_faccing_to(target, delta):
	var global_pos = global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(target.x,global_pos.y,target.z),Vector3(0,1,0))
	global_transform = global_transform.interpolate_with(wtransform, 2.5 * delta)
