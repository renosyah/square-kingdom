extends SiegeHull

onready var _owner = $owner
onready var _hp_bar = $hpBar
onready var _pivot = $pivot
onready var _tween = $Tween
onready var _tween_dead = $Tween_dead
onready var _audio = $AudioStreamPlayer3D

var _ram_weapon
var _wheels
var _flag

############################################################
# multiplayer func
func _set_puppet_moving_state(_val : Dictionary):
	._set_puppet_moving_state(_val)
	if is_dead:
		return
		
	for i in _wheels:
		if moving_state.is_walking:
			i.rotate_wheel()
		else:
			i.stop_wheel()
	
remotesync func _take_damage(_damage : float, _hit_by: Dictionary):
	._take_damage(_damage, _hit_by)
	
	if is_dead:
		return
		
	_hp_bar.update_bar(hp,max_hp)
	_tween.interpolate_property(_hp_bar, "modulate:a", 1 , 0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
		
remotesync func _perform_attack():
	._perform_attack()
	
	_ram_weapon.attack()
	
	_audio.stream = preload("res://assets/sound/cant_click.wav")
	_audio.play()
	
remotesync func _dead():
	._dead()
	
	spawn_explosive()
	break_random_part(_pivot)
	
	_audio.stream = load("res://assets/sound/explode3.wav")
	_audio.play()
	
	_tween_dead.interpolate_property(_pivot, "translation:y", _pivot.translation.y , -4, 5.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween_dead.start()
	
############################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	if not player.empty():
		_owner.set_message(player.name)
		
	_hp_bar.show_label(false)
	_hp_bar.set_hp_bar_color(color)
	_hp_bar.update_bar(hp,max_hp)
	_hp_bar.modulate.a = 0.0
	
	set_process(true)
	init_siege()
	
func init_siege():
	_ram_weapon = $pivot/ram
	_wheels = [$pivot/wheel_1, $pivot/wheel_2, $pivot/wheel_3, $pivot/wheel_4,$pivot/wheel_5, $pivot/wheel_6]
	_flag = $pivot/flag
	_flag.set_flag_color(color)
	
	
func transform_turning(direction, delta):
	var new_transform = transform.looking_at(direction, Vector3.UP)
	transform = transform.interpolate_with(new_transform, turn_speed * delta)
	
func perform_attack():
	.perform_attack()
	
	if not is_master():
		return
		
	if target is Building:
		target.capture(
			capture_damage, Utils.create_hit_by(player, self.get_path(), team, color)
		)
		
	else:
		target.take_damage(
			attack_damage,
			Utils.create_hit_by(player, self.get_path(), team, color)
		)
	
	
func _on_Tween_dead_tween_completed(object, key):
	emit_signal("on_dead", self)
	
	
func display_player_name(_show : bool):
	.display_player_name(_show)
	_owner.visible = _show

func _on_VisibilityNotifier_screen_entered():
	_pivot.visible = true
	
func _on_VisibilityNotifier_screen_exited():
	_pivot.visible = false




