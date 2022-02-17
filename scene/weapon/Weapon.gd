extends Spatial
class_name Weapon

const MELEE_ATTACK_SOUND = [
		"res://assets/sound/fight1.wav",
		"res://assets/sound/fight2.wav",
		"res://assets/sound/fight3.wav",
		"res://assets/sound/fight4.wav",
		"res://assets/sound/fight5.wav"
]
const BOW_ATTACK_SOUND = [
		"res://assets/sound/stab1.wav",
		"res://assets/sound/stab2.wav",
]

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
