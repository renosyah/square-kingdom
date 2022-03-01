extends StaticBody
class_name Building

signal on_ready(_unit)
signal on_building_captured(_building)
signal on_building_recaptured(_building)
signal on_capture_progress(_building, _capture_by, _cp_damage, _cp, _max_cp)
signal on_recapture_progress(_building, _cp_damage_restore, _cp, _max_cp)

# base
var player = {}
var type_building = ""

# attr
var cp : float = 100.0
var max_cp : float = 100.0
var cp_regen_rate : float = 8.0

# tag
var building_name = ""
var team : String = ""
var color : Color = Color.white

# capture
var capture_by : Dictionary = {player = {}, team = "", color = Color.white}
var last_owner_team = ""
var can_be_capture = true

# misc
var _network_timmer : Timer = null
var _capture_reset_timer : Timer = null

############################################################
# multiplayer func
func _network_timmer_timeout():
	if is_master():
		rset_unreliable("_puppet_cp", cp)
		
puppet var _puppet_cp :float setget _set_puppet_cp
func _set_puppet_cp(_val :float):
	_puppet_cp = _val
	cp = _puppet_cp
	
remotesync func _recapture(_cp_damage_restore : float):
	emit_signal("on_recapture_progress", self, _cp_damage_restore, cp, max_cp)
	
remotesync func _finish_recaptured():
	emit_signal("on_building_recaptured", self)
	
remotesync func _capture(_cp_damage : float, _capture_by: Dictionary):
	capture_by = _capture_by
	emit_signal("on_capture_progress", self, capture_by, _cp_damage, cp, max_cp)
	
remotesync func _finish_captured(_capture_by: Dictionary):
	capture_by = _capture_by
	last_owner_team = team
	team = capture_by.team
	color = capture_by.color
	player = capture_by.player
	cp = max_cp
	
	emit_signal("on_building_captured", self)
	
############################################################
func set_data(_data):
	building_name = _data.name
	type_building = _data.type_building
	cp = _data.cp
	max_cp = _data.max_cp
	cp_regen_rate = _data.cp_regen_rate
	team = _data.team 
	color = _data.color
	last_owner_team = team
	
func _ready():
	if not is_master():
		return
	
	if not _capture_reset_timer:
		_capture_reset_timer = Timer.new()
		_capture_reset_timer.wait_time = cp_regen_rate
		_capture_reset_timer.connect("timeout", self , "_capture_reset_timer_timeout")
		_capture_reset_timer.autostart = true
		add_child(_capture_reset_timer)
		
	if not _network_timmer:
		_network_timmer = Timer.new()
		_network_timmer.wait_time = 2.0
		_network_timmer.connect("timeout", self , "_network_timmer_timeout")
		_network_timmer.autostart = true
		add_child(_network_timmer)
		
func capture(_cp_damage : float, _capture_by: Dictionary):
	if not can_be_capture:
		return
		
	if not is_master():
		return
		
	cp -= _cp_damage
	capture_by = _capture_by
	
	if cp < 1 and capture_by.team != team:
		finish_captured(capture_by)
		
	rpc_unreliable("_capture", _cp_damage, _capture_by)
	
func recapture(_cp_damage_restore : float):
	if not is_master():
		return
		
	if cp + _cp_damage_restore >= max_cp:
		cp = max_cp
		finish_recaptured()
		return
		
	if cp < max_cp:
		cp += _cp_damage_restore
		
	rpc_unreliable("_recapture", _cp_damage_restore)
	
	
func _capture_reset_timer_timeout():
	if not is_master():
		return
		
	if cp < max_cp:
		recapture(cp_regen_rate)
	
func finish_captured(_capture_by : Dictionary):
	if not is_master():
		return
	
	rpc("_finish_captured", _capture_by)
	
func finish_recaptured():
	if not is_master():
		return
	
	rpc("_finish_recaptured")
	
	
func is_master() -> bool:
	if not get_tree().network_peer:
		return false
	
	if not is_network_master():
		return false
		
	return true
	
func is_targetable(_team):
	return team != _team





