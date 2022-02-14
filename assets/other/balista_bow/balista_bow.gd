extends Spatial

onready var _animation = $AnimationPlayer

func shot():
	_animation.play("firing")
	
func stop():
	_animation.play("firing")
