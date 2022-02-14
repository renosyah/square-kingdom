extends Spatial

onready var _animation = $AnimationPlayer

func attack():
	_animation.play("attack")
	
func stop_attack():
	_animation.play("stop")
