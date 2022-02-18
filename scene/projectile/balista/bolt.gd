extends "res://scene/projectile/projectile.gd"

var _sound

func _ready():
	_sound = AudioStreamPlayer3D.new()
	_sound.stream = preload("res://assets/sound/explode2.wav")
	_sound.unit_db = 8
	_sound.unit_size = 8
	_sound.bus = "sfx"
	add_child(_sound)

func stop_projectile():
	.stop_projectile()
	for i in _sprites:
		i.visible = false
		
	spawn_explosive()
	_sound.play()
	
func spawn_explosive():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	explosive.scale = Vector3.ONE * 8
	add_child(explosive)
	explosive.translation = translation
