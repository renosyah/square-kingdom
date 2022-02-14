extends Control

onready var _input_name = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/player_name_setting/input_name

onready var _team_1_color = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/HBoxContainer/team_1_setting/hbox/color
onready var _team_2_color = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/HBoxContainer/team_2_setting/hbox/color

onready var _ai_label = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/Label4
onready var _easy_button = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/ai_setting/easy_btn
onready var _medium_button = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/ai_setting/medium
onready var _hard_button = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/ai_setting/hard


# Called when the node enters the scene tree for the first time.
func _ready():
	set_current_setting()
	get_tree().set_quit_on_go_back(true)
	get_tree().set_auto_accept_quit(true)

func set_current_setting():
	_input_name.placeholder_text = Global.player_data.name
	
	_team_1_color.color = Global.player_game_data[Global.TEAM_1].color
	_team_2_color.color = Global.player_game_data[Global.TEAM_2].color
	
	apply_diff()
	
func set_all_enable():
	_easy_button.disabled = false
	_medium_button.disabled = false
	_hard_button.disabled = false

func apply_diff():
	_ai_label.text = "Bot Difficulty : " + Global.player_game_data.ai_level.name
	_easy_button.disabled = (Global.player_game_data.ai_level.name == Global.EASY_AI)
	_medium_button.disabled = (Global.player_game_data.ai_level.name == Global.MEDIUM_AI)
	_hard_button.disabled = (Global.player_game_data.ai_level.name == Global.HARD_AI)

func _on_back_pressed():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")

func _on_save_name_pressed():
	if _input_name.text == "":
		return
		
	Global.player_data.name = _input_name.text
	Global.save_player_data()
	
func _on_team_1_randomize_color_pressed():
	var color = Color(randf(), randf(), randf(), 1.0)
	_team_1_color.color = color
	Global.player_game_data[Global.TEAM_1].color = color
	
	for i in Global.player_game_data[Global.TEAM_1].units:
		if i.team == Global.TEAM_1:
			i.color = color
		
	for i in Global.player_game_data.buildings:
		if i.team == Global.TEAM_1:
			i.color = color
		
	Global.save_player_game_data()
	
func _on_team_2_randomize_color_pressed():
	var color = Color(randf(), randf(), randf(), 1.0)
	_team_2_color.color = color
	Global.player_game_data[Global.TEAM_2].color = color
	
	for i in Global.player_game_data[Global.TEAM_1].units:
		if i.team == Global.TEAM_1:
			i.color = color
		
	for i in Global.player_game_data.buildings:
		if i.team == Global.TEAM_1:
			i.color = color
		
	Global.save_player_game_data()
	
func _on_easy_btn_pressed():
	set_all_enable()
	Global.player_game_data.ai_level = Global.AI_LEVEL[Global.EASY_AI]
	apply_diff()
	Global.save_player_game_data()
	
func _on_medium_pressed():
	set_all_enable()
	Global.player_game_data.ai_level = Global.AI_LEVEL[Global.MEDIUM_AI]
	apply_diff()
	Global.save_player_game_data()
	
func _on_hard_pressed():
	set_all_enable()
	Global.player_game_data.ai_level = Global.AI_LEVEL[Global.HARD_AI]
	apply_diff()
	Global.save_player_game_data()


















