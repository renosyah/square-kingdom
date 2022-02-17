extends Weapon

func _ready():
	attack_animations = [
		"sword_attack_1",
		"sword_attack_2",
		"pike_attack_1"
	]
	
	attack_sounds = MELEE_ATTACK_SOUND
