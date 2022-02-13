extends Spatial
class_name Weapon

var attack_animations = []
var attack_sounds = []

func get_attack_sound() -> String:
	if attack_sounds.empty():
		return ""
		
	return attack_sounds[randi() % attack_sounds.size()]

func perform_attack() -> String:
	if attack_animations.empty():
		return ""
		
	return attack_animations[randi() % attack_animations.size()]
