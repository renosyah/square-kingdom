extends Sprite3D

const MAX_DISTANCE = 10.0

onready var _message = $Viewport/HBoxContainer/message
onready var _viewport = $Viewport

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = _viewport.get_texture()
	set_as_toplevel(true)
	
func set_color(_color : Color):
	_message.modulate = _color
	
func set_message(_msg):
	_message.text = _msg
