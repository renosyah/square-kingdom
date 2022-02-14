extends Building

signal on_coin_produce(_for_team, _with_amount)

onready var _flag = $flag
onready var _message = $message_3d
onready var _tween = $Tween
onready var _timer = $coin_gain_timer
onready var _capture_reset_timer = $capture_reset_timer
onready var _cp_bar = $hpBar

var amount = 0
var coin_produce_cooldown = 10

############################################################
# multiplayer func
remotesync func _display_message(_msg):
	_message.set_message(_msg)
	_message.set_color(Color(1, 0.776471, 0.364706))
	_message.visible = true
	_tween.interpolate_property(_message, "translation:y", 0 , 10, 2.3, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.interpolate_property(_message, "modulate:a", 1 , 0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
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
	amount = _data.amount
	coin_produce_cooldown = _data.coin_produce_cooldown
	
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
	
func _on_coin_gain_timer_timeout():
	if not .is_master():
		return
		
	var _amount = amount if amount > 0 else int(rand_range(2,8))
	rpc("_display_message", "+" + str(_amount))
	emit_signal("on_coin_produce",team,_amount)
	
func _on_capture_reset_timer_timeout():
	if not .is_master():
		return
		
	if cp < max_cp:
		.recapture(cp_regen_rate)











