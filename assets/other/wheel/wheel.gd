extends Sprite3D

onready var _animation = $AnimationPlayer

func rotate_wheel():
	if _animation.current_animation == "wheel_rotate":
		return
		
	_animation.play_backwards("wheel_rotate")
	
func stop_wheel():
	if _animation.current_animation == "stop":
		return
		
	_animation.play("stop")
