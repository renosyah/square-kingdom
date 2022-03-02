extends "res://scene/units/mounted_melee/mounted_melee.gd"

onready var _shot_delay = $shot_delay
var projectile_scene = ""

func set_data(_data):
	.set_data(_data)
	projectile_scene = _data.projectile_scene
	
func _ready():
	_shot_delay.wait_time = attack_cooldown
	
func perform_attack():
	#.perform_attack()
	
	if not is_master():
		return
		
	if target is Building:
		target.capture(
			capture_damage,
			Utils.create_hit_by(player, self.get_path(), team, color)
		)
	
func moving(delta):
	.moving(delta)
	
	if is_dead:
		return
		
	if not target:
		return
		
	if not is_instance_valid(target):
		return
		
	if not target.is_targetable(team):
		return
		
	var distance_to_target = translation.distance_to(target.translation)
	if distance_to_target <= range_attack + 5.0:
		if _shot_delay.is_stopped():
			_fire()
			_shot_delay.start()
		
func _fire():
	var arrow = load(projectile_scene).instance()
	arrow.attack_damage = attack_damage
	arrow.team = team
	arrow.color = color
	arrow.player = player
	arrow.is_master = is_master()
	arrow.spread = 0.4
	add_child(arrow)
	arrow.translation = translation
	arrow.translation.y += 2
	arrow.launch(target.translation)
	
	._perform_attack()


