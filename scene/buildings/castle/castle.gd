extends Building

signal on_coin_produce(_for_team, _with_amount)

# attack
var attack_damage = 4.0
var attack_cool_down = 2.2
var range_attack = 50.0

# target
var target = null # other unit node
var _cooldown_timmer : Timer = null

onready var _flag = $flag
onready var _message = $message_3d
onready var _tween = $Tween
onready var _timer = $coin_gain_timer
onready var _capture_reset_timer = $capture_reset_timer
onready var _cp_bar = $hpBar

var amount = 10
var coin_produce_cooldown = 10

############################################################
# multiplayer func
remotesync func _display_message(_msg):
	_message.set_message(_msg)
	_message.set_color(Color(1, 0.776471, 0.364706))
	_message.visible = true
	_tween.interpolate_property(_message, "translation:y", 8 , 14, 2.5, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.interpolate_property(_message, "modulate:a", 1 , 0, 2.3, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
remotesync func _shot_at(target_translation : Vector3):
	var arrow = preload("res://scene/projectile/arrow/arrow.tscn").instance()
	arrow.attack_damage = attack_damage
	arrow.team = team
	arrow.color = color
	arrow.is_master = is_master()
	add_child(arrow)
	arrow.translation = translation
	arrow.translation.y += 4
	arrow.launch(target_translation)
	
remotesync func _recapture(_cp_damage_restore : float):
	._recapture(_cp_damage_restore)
	_cp_bar.update_bar(cp, max_cp)
	_cp_bar.modulate.a = 1
	
remotesync func _finish_recaptured():
	._finish_recaptured()
	_flag.set_flag_color(color)
	_cp_bar.set_hp_bar_color(color)
	_cp_bar.modulate.a = 1
	_tween.interpolate_property(_cp_bar, "modulate:a", 1 , 0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
remotesync func _capture(_cp_damage : float, _capture_by: Dictionary):
	._capture(_cp_damage, _capture_by)
	_cp_bar.update_bar(cp, max_cp)
	_cp_bar.modulate.a = 1
	
	if not .is_master():
		return
		
	var _aggresor = get_node_or_null(_capture_by.node_path)
	if is_instance_valid(_aggresor):
		target = _aggresor
		
remotesync func _finish_captured():
	._finish_captured()
	_flag.set_flag_color(color)
	_cp_bar.set_hp_bar_color(color)
	_cp_bar.modulate.a = 1
	_tween.interpolate_property(_cp_bar, "modulate:a", 1 , 0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
############################################################
func set_data(_data):
	.set_data(_data)
	attack_damage =_data.attack_damage
	attack_cool_down = _data.attack_cool_down
	range_attack = _data.range_attack
	amount = _data.amount
	coin_produce_cooldown = _data.coin_produce_cooldown
	
# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	_flag.set_flag_color(color)
	_cp_bar.show_label(false)
	_cp_bar.set_hp_bar_color(color)
	_cp_bar.update_bar(cp,max_cp)
	_cp_bar.modulate.a = 0.0

	if not .is_master():
		return
	
	if amount != 0:
		_timer.wait_time = coin_produce_cooldown
		_timer.start()
	
	_capture_reset_timer.wait_time = 5
	_capture_reset_timer.start()
	
	if not _cooldown_timmer:
		_cooldown_timmer = Timer.new()
		_cooldown_timmer.wait_time = attack_cool_down
		_cooldown_timmer.autostart = false
		_cooldown_timmer.one_shot = true
		add_child(_cooldown_timmer)
		
	emit_signal("on_ready", self)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	# is a puppet
	if not is_master():
		return
		
	if is_instance_valid(target):
		var distance_to_target = translation.distance_to(target.translation)
		
		if not target.is_targetable(team) or distance_to_target > range_attack:
			target = null
			
		elif distance_to_target <= range_attack and _cooldown_timmer.is_stopped():
			shot_at(target.translation)
			_cooldown_timmer.start()
		
func shot_at(target_translation : Vector3):
	if not .is_master():
		return
		
	rpc("_shot_at", target_translation)
	
	
func _on_coin_gain_timer_timeout():
	if not .is_master():
		return
		
	if amount == 0:
		return
		
	rpc("_display_message", "+" + str(amount))
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




