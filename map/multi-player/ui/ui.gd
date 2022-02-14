extends Control

signal on_deploy_card(_card)

onready var _control_ui = $CanvasLayer/Control

onready var _pop_cap = $CanvasLayer/Control/HBoxContainer3/HBoxContainer2/label
onready var _coin = $CanvasLayer/Control/HBoxContainer3/HBoxContainer/label
onready var _hurt = $CanvasLayer/Control/hurt_effect
onready var _deck_list = $CanvasLayer/Control/HBoxContainer2/deck_list
onready var _info = $CanvasLayer/Control/info
onready var _tween = $Tween

onready var _loading = $CanvasLayer/loading
onready var _loading_message = $CanvasLayer/loading/label2

onready var _game_over = $CanvasLayer/game_over
onready var _game_over_condition = $CanvasLayer/game_over/VBoxContainer/label2
onready var _game_over_message = $CanvasLayer/game_over/VBoxContainer/label3
onready var _game_over_rematch_btn = $CanvasLayer/game_over/VBoxContainer/HBoxContainer/re_match
onready var _game_over_rematch_tip = $CanvasLayer/game_over/VBoxContainer/label4

onready var _menu = $CanvasLayer/menu

func _ready():
	_menu.visible = false
	_game_over.visible = false
	_control_ui.visible = false
	_loading.visible = true
	
func _on_menu_btn_pressed():
	_menu.visible = true
	_control_ui.visible = false
	
func _on_close_menu_pressed():
	_menu.visible = false
	_control_ui.visible = true
	
func display_info(_message : String):
	_info.text = _message
	_tween.interpolate_property(_info, "modulate:a", 1 , 0.0, 4.0)
	_tween.start()
		
func display_coin( _amount : int):
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
	
func display_game_over(show_rematch : bool , condition, message : String):
	_game_over_rematch_btn.visible = show_rematch
	_control_ui.visible = false
	_game_over.visible = true
	_game_over_condition.text = condition
	_game_over_message.text = message
	_game_over_rematch_tip.text = "You can rematch or leave" if get_tree().is_network_server() else "You can wait for rematch or leave"
	
func display_hurt(_team : String):
	if _team == Global.player_data.team:
		_tween.interpolate_property(_hurt, "modulate:a", 1 , 0.0, 1.0)
		_tween.start()
	
func _on_deck_list_on_item_press(data):
	emit_signal("on_deploy_card", data)
	
func _on_exit_game_pressed():
	if get_tree().is_network_server():
		Network.disconnect_from_server()
		
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")

func _on_re_match_pressed():
	if not get_tree().is_network_server():
		return
		
	get_tree().change_scene("res://map/multi-player/host/battle.tscn")
	
func _on_force_exit_pressed():
	Network.disconnect_from_server()
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")













