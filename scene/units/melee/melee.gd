extends Unit

onready var _owner = $owner
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
		return
		
	_tween.interpolate_property(self,"translation", translation, _puppet_translation, 0.5)
	_tween.start()
	
	
func _set_puppet_moving_state(_val : Dictionary):
	._set_puppet_moving_state(_val)
	if is_dead:
		return
		
	if moving_state.is_walking:
		_state.travel("walking")
		
	else:
		_state.travel("idle")
		
	if _pivot.scale.x != moving_state.facing_direction:
		_tween.interpolate_property(_pivot,"scale:x", _pivot.scale.x, moving_state.facing_direction, 0.1)
		_tween.start()

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
		
	if not player.empty():
		_owner.set_message(player.name)
		
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
		target.capture(
			capture_damage, 
			Utils.create_hit_by(player, self.get_path(), team, color)
		)
	else:
		target.take_damage(
			attack_damage,
			Utils.create_hit_by(player, self.get_path(), team, color)
		)
	
func _on_finish_died():
	emit_signal("on_dead", self)
	
	
func display_player_name(_show : bool):
	.display_player_name(_show)
	_owner.visible = _show
	
func _on_VisibilityNotifier_screen_entered():
	_pivot.visible = true
	
func _on_VisibilityNotifier_screen_exited():
	_pivot.visible = false


