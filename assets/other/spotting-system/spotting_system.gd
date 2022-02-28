extends Spatial

signal on_spotted(_node)

onready var _raycasts = [$north, $east, $west]

var use_multiple = true setget _set_use_multiple
var team = ""
var spotting_range : int setget _set_spotting_range
var enable : bool setget _set_enable
var parent setget _set_parent
var direction : Vector3 setget _set_direction
	
func _set_use_multiple(_val : bool):
	use_multiple = _val
	if use_multiple:
		_raycasts[0].enabled = true
		_raycasts[1].enabled = true
		_raycasts[2].enabled = true
		
		_raycasts[0].visible = true
		_raycasts[1].visible = true
		_raycasts[2].visible = true
	else:
		_raycasts[0].enabled = true
		_raycasts[1].enabled = false
		_raycasts[2].enabled = false
		
		_raycasts[0].visible = true
		_raycasts[1].visible = false
		_raycasts[2].visible = false
	
func _set_direction(_val):
	direction = _val
	look_at(direction, Vector3.UP)
	
func _set_spotting_range(_val : int):
	spotting_range = _val
	for i in _raycasts:
		i.cast_to = i.cast_to * spotting_range
	
func _set_enable(_enable):
	enable = _enable
	set_process(enable)
	
func _set_parent(_node):
	parent = _node
	for i in _raycasts:
		i.add_exception(parent)
	
func _ready():
	set_process(false)
	
func _process(delta):
	for i in _raycasts:
		if i.is_colliding():
			var body = i.get_collider()
			if _is_valid_target(body):
				emit_signal("on_spotted", body)
				set_process(false)
				return
			
func _is_valid_target(_body) -> bool:
	if not is_instance_valid(_body):
		return false
		
	if _body is StaticBody:
		return false
		
	if not _body.is_targetable(team):
		return false
		
	return true
	
