extends Building

onready var _pivots = {"PV_1" : $pivot1,"PV_2" : $pivot2}
onready var _flag = $flag
onready var _tween = $Tween
onready var _capture_reset_timer = $capture_reset_timer
onready var _cp_bar = $hpBar

var pivot : String
var upgrades : Dictionary

############################################################
# multiplayer func
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
	upgrades = _data.upgrades
	pivot = _data.pivot
	
# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	_flag.set_flag_color(color)
	_cp_bar.show_label(false)
	_cp_bar.set_hp_bar_color(color)
	_cp_bar.update_bar(cp,max_cp)
	_cp_bar.modulate.a = 0.0
	
	_pivots[pivot].visible = true
	
	if not .is_master():
		return
		
	_capture_reset_timer.wait_time = 5
	_capture_reset_timer.start()
	
func upgrade_to_text() -> String:
	var msg = ""
	
	if not upgrades:
		return ""
	
	for attribute in upgrades.keys():
		msg = str(int(upgrades[attribute].value * 100.0)) + "% of " + upgrades[attribute].name
		
	return msg

func apply_upgrade(_unit):
	if not .is_master():
		return
		
	if not upgrades:
		return
		
	if upgrades.empty():
		return
		
	for attribute in upgrades.keys():
		_unit[attribute] = _unit[attribute] * upgrades[attribute].value
		
		if attribute == "max_hp":
			_unit["hp"] = _unit[attribute]
	

func _on_capture_reset_timer_timeout():
	if not .is_master():
		return
		
	if cp < max_cp:
		.recapture(cp_regen_rate)
	
	
func _on_VisibilityNotifier_screen_entered():
	visible = true


func _on_VisibilityNotifier_screen_exited():
	visible = false



