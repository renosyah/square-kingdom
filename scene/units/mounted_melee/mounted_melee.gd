extends "res://scene/units/melee/melee.gd"

var mount
var mount_scene = ""

func _set_puppet_moving_state(_val : Dictionary):
	._set_puppet_moving_state(_val)
	if is_dead:
		return
		
	if moving_state.is_walking:
		mount.walk()
	else:
		mount.stop()
	
func set_data(_data):
	.set_data(_data)
	mount_scene = _data.mount_scene
	
	
func _ready():
	mount = load(mount_scene).instance()
	$pivot/upper_body.add_child(mount)
	mount.translation = $pivot/upper_body/mount.translation
	
	$pivot/upper_body/leg_3.modulate = color
