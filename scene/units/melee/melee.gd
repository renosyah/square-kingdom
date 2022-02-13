extends Unit

onready var _hp_bar = $hpBar
onready var _pivot = $pivot
onready var _tween = $Tween
onready var _state = $AnimationTree.get("parameters/playback")
onready var _bodies = [$pivot/upper_body/body, $pivot/leg_1, $pivot/leg_2, $pivot/upper_body/arm_1, $pivot/upper_body/arm_2]
onready var _audio = $AudioStreamPlayer3D

var _primary_weapon
var _secondary_weapon

############################################################
# multiplayer func
func _set_puppet_translation(_val :Vector3):
	._set_puppet_translation(_val)
	
	if is_dead:
		translation = _puppet_translation
		return
		
	_tween.interpolate_property(self,"translation", translation, _puppet_translation, 0.3)
	_tween.start()
	
	
remotesync func _set_facing_direction(_val : int):
	._set_facing_direction(_val)
	
	if is_dead:
		_pivot.scale.x = facing_direction
		return
		
	_tween.interpolate_property(_pivot,"scale:x", _pivot.scale.x, facing_direction, 0.1)
	_tween.start()
	
remotesync func _set_walking_state(_val : bool):
	._set_walking_state(_val)
	
	if is_walking:
		_state.travel("walking")
	else:
		_state.travel("idle")
	
remotesync func _take_damage(_damage : float, _hit_by: Dictionary):
	._take_damage(_damage, _hit_by)
	
	if is_dead:
		return
		
	_hp_bar.update_bar(hp,max_hp)
	_tween.interpolate_property(_hp_bar, "modulate:a", 1 , 0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
		
remotesync func _perform_attack():
	._perform_attack()
	
	if not _primary_weapon and primary_weapon_scene == "":
		return
		
	if _primary_weapon.perform_attack() == "":
		return
		
	_state.travel(_primary_weapon.perform_attack())
	
	if _primary_weapon.get_attack_sound() == "":
		return
	
	_audio.stream = load(_primary_weapon.get_attack_sound())
	_audio.play()
	
remotesync func _dead():
	._dead()
	_state.travel("die")
	
	_audio.stream = load(dead_sounds[randi() % dead_sounds.size()])
	_audio.play()
	
############################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in _bodies:
		i.modulate = color
		
	_hp_bar.show_label(false)
	_hp_bar.set_hp_bar_color(color)
	_hp_bar.update_bar(hp,max_hp)
	_hp_bar.modulate.a = 0.0
	
	if primary_weapon_scene != "":
		_primary_weapon = load(primary_weapon_scene).instance()
		$pivot/upper_body/arm_1.add_child(_primary_weapon)
		
	if secondary_weapon_scene != "":
		_secondary_weapon = load(secondary_weapon_scene).instance()
		$pivot/upper_body/arm_2.add_child(_secondary_weapon)
		
	if helm != "":
		$pivot/upper_body/head.texture = load(helm)
		
	if armor != "":
		$pivot/upper_body/armor.texture = load(armor)

func perform_attack():
	.perform_attack()
	
	if not is_master():
		return
		
	if target is Building:
		target.capture(capture_damage, {node_path = self.get_path(), team = team, color = color})
	else:
		target.take_damage(attack_damage, {node_path = self.get_path(), team = team, color = color})
	
func _on_finish_died():
	emit_signal("on_dead", self)
	
	
	
	



