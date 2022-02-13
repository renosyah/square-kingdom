extends Spatial

export(Color) var color = Color.white
onready var _sprite = $Sprite3D

func _ready():
	set_flag_color(color)

func set_flag_color(_color):
	_sprite.modulate = _color
