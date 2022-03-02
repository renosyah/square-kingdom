extends Control

const PLAYER_STATUS_NOT_READY = "NOT_READY"
const PLAYER_STATUS_READY = "READY"

onready var _server_advertise = $server_advertise

onready var _loading = $CanvasLayer/loading
onready var _control_ui = $CanvasLayer/Control

onready var _player_holder = $CanvasLayer/Control/VBoxContainer2/players/VBoxContainer
onready var _battle_layout = $CanvasLayer/Control/VBoxContainer2/VBoxContainer/battle

onready var _team_1_color = $CanvasLayer/Control/VBoxContainer2/VBoxContainer/choose_side/join_team_1/ColorRect2
onready var _team_2_color = $CanvasLayer/Control/VBoxContainer2/VBoxContainer/choose_side/join_team_2/ColorRect

onready var _battle_button = $CanvasLayer/Control/VBoxContainer2/VBoxContainer/battle/battle
onready var _exit_timer = $exit_timer
onready var _enter_game_timer = $enter_game_timer

onready var _dialog_exit_option = $CanvasLayer/simple_dialog_option

var team_colors = {
	Global.TEAM_1 : Color.blue,
	Global.TEAM_2 : Color.red
}
################################################################
# sync lobby
var player_joined : Array = []

class MyCustomSorter:
	static func sort(a, b):
		if a["id"] < b["id"]:
			return true
		return false
		
remote func _request_append_player_joined(from : int, data : Dictionary):
	for i in player_joined:
		if i.id == data.id:
			player_joined.erase(i)
			break
			
	player_joined.append(data)
	rpc("_update_player_joined", player_joined)
	
remote func _request_erase_player_joined(data : Dictionary):
	for i in player_joined:
		if i.id == data.id:
			player_joined.erase(i)
			break
			
	rpc("_update_player_joined", player_joined)
	
remotesync func _update_player_joined(data : Array):
	if get_tree().is_network_server():
		_server_advertise.serverInfo["player"] = player_joined.size()
	else:
		player_joined = data
		
	player_joined.sort_custom(MyCustomSorter, "sort")
	fill_player_slot()
	
remotesync func _kick_player(data : Dictionary):
	for i in player_joined:
		if i.id == data.id:
			player_joined.erase(i)
			break
			
	if data.id == Global.player_data.id:
		Network.connect("connection_closed", self , "_got_kickout")
		Network.disconnect_from_server()
		return
		
	fill_player_slot()
	
remote func _request_team_colors_data(from_id : int):
	if not get_tree().is_network_server():
		return
		
	rpc_id(from_id, "_receive_host_game_data", team_colors)
	
remote func _receive_host_game_data(_team_colors : Dictionary):
	team_colors = _team_colors
	_loading.visible = false
	_control_ui.visible = true
	_team_1_color.color = team_colors[Global.TEAM_1]
	_team_2_color.color = team_colors[Global.TEAM_2]
	
	var data = {
		id = Global.player_data.id,
		name = Global.player_data.name,
		color = Color.gray,
		team = "",
		status = "Not Ready",
		flag = PLAYER_STATUS_NOT_READY
	}
	rpc_id(Network.PLAYER_HOST_ID, "_request_append_player_joined",Global.client.network_unique_id, data)
	
	
remotesync func _battle():
	if get_tree().is_network_server():
		_enter_game_timer.start()
		
	_loading.visible = true
	_control_ui.visible = false
	
################################################################

func _ready():
	_loading.visible = true
	_control_ui.visible = false
	_battle_button.disabled = true
	
	if Global.mode == Global.MODE_HOST:
		_init_host()
		
	elif Global.mode == Global.MODE_JOIN:
		_init_join()
		
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_back_pressed()
			return
		
################################################################
# host player section
func _init_host():
	_battle_layout.visible = true
	
	for i in Global.TEAMS:
		team_colors[i] = Global.player_game_data[i].color
		
	_team_1_color.color = team_colors[Global.TEAM_1]
	_team_2_color.color = team_colors[Global.TEAM_2]
	
	Network.connect("server_player_connected", self ,"_server_player_connected")
	var err = Network.create_server(Global.server.max_player, Global.server.port , {"name" : Global.player_data.name})
	if err != OK:
		return
	
func _server_player_connected(_player_network_unique_id : int, _player : Dictionary):
	_loading.visible = false
	_control_ui.visible = true
	
	var data = {
		id = Global.player_data.id,
		name = Global.player_data.name,
		color = Color.gray,
		team = "",
		status = "Not Ready",
		flag = PLAYER_STATUS_NOT_READY
	}
	_request_append_player_joined(Global.client.network_unique_id, data)
	
	_server_advertise.setup()
	_server_advertise.serverInfo["name"] = Global.player_data.name
	_server_advertise.serverInfo["port"] = Global.server.port
	_server_advertise.serverInfo["public"] = true
	_server_advertise.serverInfo["player"] = player_joined.size()
	_server_advertise.serverInfo["max_player"] = Global.server.max_player
	
################################################################
# join player section
func _init_join():
	_battle_layout.visible = false
	
	Global.connect("on_host_game_session_ready", self, "_on_host_game_session_ready")
	Network.connect("server_disconnected", self , "_server_disconnected")
	Network.connect("client_player_connected", self , "_client_player_connected")
	
	var err = Network.connect_to_server(Global.client.ip, Global.client.port , {"name" : Global.player_data.name})
	if err != OK:
		return
	
func _client_player_connected(_player_network_unique_id : int, player : Dictionary):
	Global.client.network_unique_id = _player_network_unique_id
	rpc_id(Network.PLAYER_HOST_ID, "_request_team_colors_data", _player_network_unique_id)
	
func _on_host_game_session_ready(_mp_game_data : Dictionary):
	Global.mp_game_data = _mp_game_data
	get_tree().change_scene("res://map/multi-player/client/battle.tscn")
	
func _server_disconnected():
	Global.mp_exception_message = "Unexpected exit by Server!"
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
func _got_kickout():
	Global.mp_exception_message = "You have been kickout by host!"
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
################################################################
# ui action
func fill_player_slot():
	for i in _player_holder.get_children():
		_player_holder.remove_child(i)
	
	var is_all_ready = true
	for i in player_joined:
		if i.flag == PLAYER_STATUS_NOT_READY:
			is_all_ready = false
			break
			
	_battle_button.disabled = (not is_all_ready)
	
	for i in player_joined:
		var item = preload("res://menu/lobby-menu/ui/item/item.tscn").instance()
		item.data = i
		item.can_kick = (i.id != Global.player_data.id and get_tree().is_network_server())
		item.connect("kick", self, "_on_player_get_kick")
		_player_holder.add_child(item)
		
func _on_player_get_kick(_player):
	if not get_tree().is_network_server():
		return
		
	rpc("_kick_player", _player)
	
func set_player_ready():
	var data = {
		id = Global.player_data.id,
		name = Global.player_data.name,
		color = Global.player_data.color,
		team = Global.player_data.team,
		status = "Ready",
		flag = PLAYER_STATUS_READY
	}
	
	if not get_tree().is_network_server():
		rpc_id(Network.PLAYER_HOST_ID, "_request_append_player_joined", Global.client.network_unique_id,data)
		return
		
	for i in player_joined:
		if i.id == data.id:
			player_joined.erase(i)
			break
		
	player_joined.append(data)
	rpc("_update_player_joined", player_joined)
	
func _on_join_team_1_pressed():
	if team_colors.empty():
		return
		
	Global.player_data.color = team_colors[Global.TEAM_1]
	Global.player_data.team = Global.TEAM_1
	Global.apply_players_unit_team()
	
	set_player_ready()
	
func _on_join_team_2_pressed():
	if team_colors.empty():
		return
		
	Global.player_data.color = team_colors[Global.TEAM_2]
	Global.player_data.team = Global.TEAM_2
	Global.apply_players_unit_team()
	
	set_player_ready()
	
func _on_battle_pressed():
	var total_player_sides = {
		Global.TEAM_1 : 0,
		Global.TEAM_2 : 0
	}
	
	for i in player_joined:
		total_player_sides[i.team] += 1
		
	Global.mp_game_data = {}
	Global.mp_game_data = Global.player_game_data.duplicate(true)
	
	# enable ai if no player in afromation team
	for i in Global.TEAMS:
		Global.mp_game_data[i].enable_ai = (total_player_sides[i] == 0)
		
	rpc("_battle")
	
func _on_back_pressed():
	_dialog_exit_option.display_message("Attention!","Are you sure want exit?")
	_dialog_exit_option.visible = true
	
func _on_exit_timer_timeout():
	Network.disconnect_from_server()
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
func _on_enter_game_timer_timeout():
	get_tree().change_scene("res://map/multi-player/host/battle.tscn")
	
func _on_simple_dialog_option_on_yes():
	if get_tree().is_network_server():
		_on_exit_timer_timeout()
		return
		
	_loading.visible = true
	_control_ui.visible = false
	_exit_timer.start()
	
	rpc("_request_erase_player_joined",{ id = Global.player_data.id})
















