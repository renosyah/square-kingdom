extends Building

signal on_coin_produce(_for_team, _with_amount)

const ARROW_SOUND = [
	preload("res://assets/sound/stab1.wav"),
	preload("res://assets/sound/stab2.wav")
]

# attack
var attack_damage = 4.0
var range_attack = 50.0

# target
var target = null # other unit node
var garrison_units = []
var garrison = []

onready var _flag = $flag
onready var _message = $message_3d
onready var _tween = $Tween
onready var _timer = $coin_gain_timer
onready var _capture_reset_timer = $capture_reset_timer
onready var _cp_bar = $hpBar

# eco
var amount : int = 10
var coin_produce_cooldown : float = 10

# misc
var parent

############################################################
# multiplayer func
remotesync func _update_amount(_amount : int):
	amount = _amount
	
remotesync func _set_target(_target : NodePath):
	var _target_node = get_node_or_null(_target)
	if not is_instance_valid(_target_node):
		return
		
	target = _target_node
	
remotesync func _recapture(_cp_damage_restore : float):
	._recapture(_cp_damage_restore)
	_cp_bar.update_bar(cp, max_cp)
	_cp_bar.modulate.a = 1
	
remotesync func _finish_recaptured():
	._finish_recaptured()
	_flag.set_flag_color(color)
	_cp_bar.set_hp_bar_color(color)
	_cp_bar.update_bar(cp, max_cp)
	_cp_bar.modulate.a = 1
	_tween.interpolate_property(_cp_bar, "modulate:a", 1 , 0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
remotesync func _capture(_cp_damage : float, _capture_by: Dictionary):
	._capture(_cp_damage, _capture_by)
	_cp_bar.update_bar(cp, max_cp)
	_cp_bar.modulate.a = 1

	var _aggresor = get_node_or_null(_capture_by.node_path)
	if is_instance_valid(_aggresor):
		target = _aggresor
		
remotesync func _finish_captured():
	._finish_captured()
	_flag.set_flag_color(color)
	_cp_bar.set_hp_bar_color(color)
	_cp_bar.update_bar(cp, max_cp)
	_cp_bar.modulate.a = 1
	_tween.interpolate_property(_cp_bar, "modulate:a", 1 , 0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
############################################################
func set_data(_data):
	.set_data(_data)
	attack_damage =_data.attack_damage
	range_attack = _data.range_attack
	amount = _data.amount
	coin_produce_cooldown = _data.coin_produce_cooldown
	garrison_units = _data.garrison_units
	
# Called when the node enters the scene tree for the first time.
func _ready():
	_flag.set_flag_color(color)
	_cp_bar.show_label(false)
	_cp_bar.set_hp_bar_color(color)
	_cp_bar.update_bar(cp,max_cp)
	_cp_bar.modulate.a = 0.0
	parent = self

	if amount != 0:
		_timer.wait_time = coin_produce_cooldown
		_timer.start()
		
	for i in garrison_units:
		var _cooldown_timmer = Timer.new()
		_cooldown_timmer.wait_time = i
		_cooldown_timmer.autostart = false
		_cooldown_timmer.one_shot = true
		
		var _sound = $AudioStreamPlayer3D.duplicate()

		garrison.append({ 
			cooldown_timmer = _cooldown_timmer,
			sound = _sound
		})
		add_child(_sound)
		add_child(_cooldown_timmer)
		
	if not .is_master():
		return
	
	_capture_reset_timer.wait_time = 5
	_capture_reset_timer.start()
	
	emit_signal("on_ready", self)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(target):
		var distance_to_target = global_transform.origin.distance_to(target.global_transform.origin)
		if distance_to_target <= range_attack:
			for i in garrison:
				if i.cooldown_timmer.is_stopped():
					shot_at(target.global_transform.origin)
					i.sound.stream = ARROW_SOUND[randi() % ARROW_SOUND.size()]
					i.sound.play()
					i.cooldown_timmer.start()
					
		elif not target.is_targetable(team) or distance_to_target > range_attack:
			if .is_master():
				target = null
				
		
func set_target(_target : NodePath):
	if not .is_master():
		return
		
	rpc("_set_target", _target)
	
func shot_at(target_translation : Vector3):
	var arrow = preload("res://scene/projectile/arrow/arrow.tscn").instance()
	arrow.attack_damage = attack_damage
	arrow.team = team
	arrow.color = color
	arrow.player = player
	arrow.is_master = is_master()
	add_child(arrow)
	arrow.parent = parent
	arrow.translation = global_transform.origin
	arrow.translation.y += 2.5
	arrow.spread = 1.8
	arrow.launch(target_translation)
	
func update_amount(_amount : int):
	if not .is_master():
		return
		
	rpc("_update_amount", _amount)
	
func show_flag(_show):
	_flag.visible = _show

func display_message(_msg):
	_message.set_message(_msg)
	_message.set_color(Color(1, 0.776471, 0.364706))
	_message.visible = true
	_tween.interpolate_property(_message, "translation:y", 8 , 14, 2.5, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.interpolate_property(_message, "modulate:a", 1 , 0, 2.3, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
func _on_coin_gain_timer_timeout():
	if amount == 0:
		return
		
	display_message("+" + str(amount))
	emit_signal("on_coin_produce",team , amount)
	
func _on_capture_reset_timer_timeout():
	if not .is_master():
		return
		
	if cp < max_cp:
		.recapture(cp_regen_rate)
	
func _on_idle_timmer_timeout():
	if not is_master():
		return
		
	if not is_instance_valid(target):
		emit_signal("on_ready", self)
		return
		
	if not target.is_targetable(team):
		emit_signal("on_ready", self)
		
func _on_VisibilityNotifier_screen_entered():
	visible = true
	
func _on_VisibilityNotifier_screen_exited():
	visible = false
