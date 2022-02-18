extends StaticBody
class_name Building

signal on_ready(_unit)
signal on_building_captured(_building)
signal on_capture_progress(_building, _capture_by, _cp_damage, _cp, _max_cp)

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

############################################################
# multiplayer func
remotesync func _recapture(_cp_damage_restore : float):
	if cp + _cp_damage_restore >= max_cp:
		cp = max_cp
		finish_recaptured()
		return
		
	if cp < max_cp:
		cp += _cp_damage_restore
		
		
remotesync func _finish_recaptured():
	pass
	
	
remotesync func _capture(_cp_damage : float, _capture_by: Dictionary):
	cp -= _cp_damage
	capture_by = _capture_by
	
	if cp < 1 and capture_by.team != team:
		finish_captured()
		
	emit_signal("on_capture_progress", self, capture_by, _cp_damage, cp, max_cp)
	
remotesync func _finish_captured():
	last_owner_team = team
	team = capture_by.team
	color = capture_by.color
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
	pass
	
func capture(_cp_damage : float, _capture_by: Dictionary):
	if not can_be_capture:
		return
		
	if not is_master():
		return
	
	rpc("_capture", _cp_damage, _capture_by)
	
func recapture(_cp_damage_restore : float):
	if not is_master():
		return
	
	rpc("_recapture", _cp_damage_restore)
	
	
	
	
func finish_captured():
	if not is_master():
		return
	
	rpc("_finish_captured")
	
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





