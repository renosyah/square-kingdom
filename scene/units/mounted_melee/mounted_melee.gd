extends "res://scene/units/melee/melee.gd"

var mount
var mount_scene = ""

remotesync func _set_walking_state(_val : bool):
	._set_walking_state(_val)
	
	if is_walking:
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
