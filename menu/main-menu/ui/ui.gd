extends Control

onready var _control_ui = $CanvasLayer/Control
onready var _exception_message = $CanvasLayer/exception_message
onready var _server_browser = $CanvasLayer/server_browser

func _ready():
	if Global.mp_exception_message != "":
		_exception_message.display_message("Network Error!", Global.mp_exception_message)
		_exception_message.visible = true
		Global.mp_exception_message = ""
		
	get_tree().set_quit_on_go_back(true)
	get_tree().set_auto_accept_quit(true)

func _on_play_pressed():
	Global.player_data.team = Global.TEAM_1
	Global.player_data.color = Color.blue
	
	Global.server.ip = '127.0.0.1'
	Global.server.port = 31400
	Global.server.max_player = 4
	
	Global.mp_game_data = Global.player_game_data
	
	Network.connect("server_player_connected", self ,"_server_player_connected")
	var err = Network.create_server(Global.server.max_player, Global.server.port , {})
	if err != OK:
		return
		
func _server_player_connected(_player_network_unique_id : int, _player : Dictionary):
	get_tree().change_scene("res://map/multi-player/host/battle.tscn")
	
func _on_setting_pressed():
	pass # Replace with function body.
	
func _on_host_pressed():
	Global.mode = Global.MODE_HOST
	get_tree().change_scene("res://menu/lobby-menu/lobby_menu.tscn")
	
func _on_join_pressed():
	_server_browser.start_finding()
	_server_browser.visible = true
	_control_ui.visible = false

func _on_server_browser_close():
	_server_browser.visible = false
	_control_ui.visible = true
	
func _on_server_browser_on_join(info):
	Global.mode = Global.MODE_JOIN
	Global.client.ip = info.ip
	get_tree().change_scene("res://menu/lobby-menu/lobby_menu.tscn")





















