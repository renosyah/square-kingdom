extends Control

onready var _control_ui = $CanvasLayer/Control
onready var _input_name = $CanvasLayer/input_name

onready var _dialog_exit_option = $CanvasLayer/simple_dialog_option
onready var _exception_message = $CanvasLayer/exception_message
onready var _server_browser = $CanvasLayer/server_browser

func _ready():
	_server_browser.start_finding()
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	check_error()
	check_player_name()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_back_pressed()
			return
			
func check_player_name():
	if Global.player_data.name == "":
		_input_name.visible = true
		_control_ui.visible = false
	
func check_error():
	if Global.mp_exception_message != "":
		_exception_message.display_message("Network Error!", Global.mp_exception_message)
		_exception_message.visible = true
		Global.mp_exception_message = ""
	
func _on_play_pressed():
	Network.connect("server_player_connected", self ,"_server_player_connected")
	var err = Network.create_server(Global.server.max_player, Global.server.port , {})
	if err != OK:
		return
		
func _server_player_connected(_player_network_unique_id : int, _player : Dictionary):
	Global.mp_game_data = Global.player_game_data.duplicate(true)
	
	Global.mp_game_data[Global.TEAM_1].enable_ai = false
	Global.mp_game_data[Global.TEAM_2].enable_ai = true
	
	Global.player_data.team = Global.TEAM_1
	Global.player_data.color = Global.mp_game_data[Global.TEAM_1].color
	Global.apply_players_unit_team()
	
	get_tree().change_scene("res://map/multi-player/host/battle.tscn")
	
func _on_setting_pressed():
	get_tree().change_scene("res://menu/setting-menu/setting_menu.tscn")

func _on_deck_pressed():
	get_tree().change_scene("res://menu/deck-menu/deck_menu.tscn")
	
func _on_host_pressed():
	Global.mode = Global.MODE_HOST
	get_tree().change_scene("res://menu/lobby-menu/lobby_menu.tscn")
	
func _on_join_pressed():
	_server_browser.visible = true
	_control_ui.visible = false
	
func _on_server_browser_close():
	_server_browser.visible = false
	_control_ui.visible = true
	
func _on_server_browser_on_join(info):
	Global.mode = Global.MODE_JOIN
	Global.client.ip = info.ip
	get_tree().change_scene("res://menu/lobby-menu/lobby_menu.tscn")

func _on_server_browser_on_error(msg):
	_exception_message.display_message("Network Error!", msg)
	_exception_message.visible = true
	Global.mp_exception_message = ""

func _on_input_name_on_continue(_player_name, html_color):
	Global.player_data.name = _player_name
	Global.save_player_data()
	_input_name.visible = false
	_control_ui.visible = true
	
func _on_back_pressed():
	_dialog_exit_option.display_message("Attention!","Are you sure want exit?")
	_dialog_exit_option.visible = true
	
func _on_simple_dialog_option_on_yes():
	get_tree().quit()
























