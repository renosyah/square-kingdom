extends Sprite3D

onready var _animation = $AnimationPlayer

func rotate_wheel():
	_animation.play_backwards("wheel_rotate")
	
func stop_wheel():
	_animation.play("stop")
