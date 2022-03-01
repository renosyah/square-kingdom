extends Control

signal on_deploy_card(_card)

onready var _control_ui = $CanvasLayer/Control

onready var _pop_cap = $CanvasLayer/Control/HBoxContainer/HBoxContainer3/HBoxContainer2/label
onready var _coin = $CanvasLayer/Control/HBoxContainer/HBoxContainer3/HBoxContainer/label
onready var _hurt = $CanvasLayer/Control/hurt_effect
onready var _deck_list = $CanvasLayer/Control/deck_list
onready var _info_title = $CanvasLayer/Control/info/VBoxContainer/info_title
onready var _info_message = $CanvasLayer/Control/info/VBoxContainer/info_message
onready var _victory_bar = $CanvasLayer/Control/HBoxContainer/CenterContainer2/vic_bar
onready var _tween = $Tween

onready var _loading = $CanvasLayer/loading
onready var _loading_message = $CanvasLayer/loading/label2

onready var _game_over = $CanvasLayer/game_over
onready var _game_over_condition = $CanvasLayer/game_over/VBoxContainer/label2
onready var _game_over_message = $CanvasLayer/game_over/VBoxContainer/label3
onready var _game_over_rematch_btn = $CanvasLayer/game_over/VBoxContainer/HBoxContainer/re_match
onready var _game_over_scoreboard = $CanvasLayer/game_over/VBoxContainer/scoreboard

onready var _reward_dialog = $CanvasLayer/reward_dialog
onready var _reward_holder = $CanvasLayer/reward_dialog/VBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/ScrollContainer/holder/HBoxContainer

onready var _fps_counter = $CanvasLayer/menu/VBoxContainer2/fps_counter
onready var _ping_counter = $CanvasLayer/menu/VBoxContainer2/ping_counter
onready var _menu = $CanvasLayer/menu
onready var _music = $CanvasLayer/menu/HBoxContainer/VBoxContainer/HBoxContainer/music
onready var _sfx = $CanvasLayer/menu/HBoxContainer/VBoxContainer/HBoxContainer/sfx

onready var exception_message = $CanvasLayer/exception_message

func _ready():
	hide_all()
	_loading.visible = true
	exception_message.visible = false
	
	_music.text = "Music : On" if Global.audio_setting.music else "Music : Off"
	_sfx.text = "Sfx : Enable" if Global.audio_setting.sfx else "Sfx : Disable"
	
	if not get_tree().is_network_server():
		_ping_counter.visible = true
		Network.connect("on_ping", self ,"_on_ping")
		
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_menu_btn_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_menu_btn_pressed()
			return
		
func _on_ping(_ping):
	_ping_counter.text = "ping : " + str(_ping) + "/ms"
	
func _on_fps_timer_timeout():
	_fps_counter.text = "fps : " + str(Engine.get_frames_per_second())
	
func _on_menu_btn_pressed():
	_menu.visible = true
	
func _on_close_menu_pressed():
	_menu.visible = false
	
func hide_all():
	_menu.visible = false
	_game_over.visible = false
	_control_ui.visible = false
	_loading.visible = false
	_reward_dialog.visible = false
	
func display_info(_title, _message : String):
	_info_title.text = _title
	_info_message.text = _message
	_tween.interpolate_property(_info_title, "modulate:a", 1 , 0.0, 4.2)
	_tween.interpolate_property(_info_message, "modulate:a", 1 , 0.0, 4.0)
	_tween.start()
	
func update_victory_bar(teams : Dictionary):
	# {team_1 : { building : 0, color : Color }, team_2 : { building : 0, color : Color }
	var _val = teams[Global.TEAM_1].building
	var _max = teams[Global.TEAM_1].building + teams[Global.TEAM_2].building
	_victory_bar.max_value = _max
	_victory_bar.tint_progress = teams[Global.TEAM_1].color
	_victory_bar.tint_under = teams[Global.TEAM_2].color
	_tween.interpolate_property(_victory_bar, "value",_victory_bar.value , _val, 1.3, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
func display_coin(_amount : int):
	_coin.text = str(_amount)
		
func display_population(_team : String , _amount : int, max_amount :int):
	if _team == Global.player_data.team:
		_pop_cap.text = str(_amount) + "/" + str(max_amount)
		
func display_clickable_deck(pop : int, max_pop : int, coin_amount : int):
	_deck_list.update_list_enable(pop < max_pop)
	_deck_list.update_list_clickable_by_cost(true, coin_amount)
	
func add_to_deck(cards : Array):
	_deck_list.update_list(cards)

func display_loading(show : bool, message : String):
	_control_ui.visible = not show
	_loading.visible = show
	_loading_message.text = message
	
func display_game_over(is_win : bool , condition, message : String, _scores : Dictionary):
	hide_all()
	_game_over.visible = true
	_game_over_condition.text = condition
	_game_over_message.text = message
	_game_over_rematch_btn.visible = get_tree().is_network_server()
	_game_over_scoreboard.display_scores(_scores)
	
	if is_win and _scores.has(Global.player_data.id):
		display_reward_dialog(_scores[Global.player_data.id]["total"])
	
	
func display_reward_dialog(total_score : int):
	var total_reward = 0
	
	if total_score >= 150:
		total_reward = 4
	elif total_score >= 100 and total_score < 150:
		total_reward = 3
	elif total_score >= 50 and total_score < 100:
		total_reward = 2
	elif total_score >= 15 and total_score < 50:
		total_reward = 1
		
	if total_reward == 0:
		return
		
	var unlocked_unit = Global.unlock_random_card_in_inventory(total_reward)
	_reward_dialog.visible = not unlocked_unit.empty()
		
		
	for i in unlocked_unit:
		var item = preload("res://menu/deck-menu/item-inventory/item.tscn").instance()
		item.data = i
		_reward_holder.add_child(item)
	
	
func display_hurt(_team : String):
	if _team == Global.player_data.team:
		_tween.interpolate_property(_hurt, "modulate:a", 1 , 0.0, 1.0)
		_tween.start()
	
func display_player_disynchronize(_player_name : String):
	exception_message.display_message("Attention!","Game session has lost connection with " + _player_name + "!")
	exception_message.visible = true
	
func _on_deck_list_on_item_press(data):
	emit_signal("on_deploy_card", data)
	
func _on_exit_game_pressed():
	Network.disconnect_from_server()
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")

func _on_re_match_pressed():
	if not get_tree().is_network_server():
		return
		
	get_tree().change_scene("res://map/multi-player/host/battle.tscn")
	
func _on_music_pressed():
	Global.audio_setting.music = not Global.audio_setting.music
	Global.play_music()
	_music.text = "Music : On" if Global.audio_setting.music else "Music : Off"
	Global.save_audio_setting()
	
func _on_sfx_pressed():
	Global.audio_setting.sfx = not Global.audio_setting.sfx
	AudioServer.set_bus_mute(AudioServer.get_bus_index("sfx"),not Global.audio_setting.sfx)
	_sfx.text = "Sfx : Enable" if Global.audio_setting.sfx else "Sfx : Disable"
	Global.save_audio_setting()
	
func _on_main_menu_pressed():
	Network.disconnect_from_server()
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")

func _on_close_exeption_message_pressed():
	_reward_dialog.visible = false
	
func _on_exception_message_on_close():
	_on_exit_game_pressed()














