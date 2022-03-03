extends Control

onready var _easy_button = $VBoxContainer/ai_setting/easy_btn
onready var _medium_button = $VBoxContainer/ai_setting/medium
onready var _hard_button = $VBoxContainer/ai_setting/hard

onready var _cap_small = $VBoxContainer/pop_cap/small_size
onready var _cap_medium = $VBoxContainer/pop_cap/medium_size
onready var _cap_huge = $VBoxContainer/pop_cap/huge_size

onready var _autoplay_btn = $VBoxContainer/autoplay/autoplay_btn

# Called when the node enters the scene tree for the first time.
func _ready():
	set_all_disabled()
	apply_btn_condition()
	
func set_all_disabled():
	_easy_button.disabled = false
	_medium_button.disabled = false
	_hard_button.disabled = false
	
	_cap_small.disabled = false
	_cap_medium.disabled = false
	_cap_huge.disabled = false


func apply_btn_condition():
	_easy_button.disabled = (Global.player_game_data.ai_level.name == Global.EASY_AI)
	_medium_button.disabled = (Global.player_game_data.ai_level.name == Global.MEDIUM_AI)
	_hard_button.disabled = (Global.player_game_data.ai_level.name == Global.HARD_AI)

	_cap_small.disabled = (Global.player_game_data.max_unit_spawn == 10)
	_cap_medium.disabled = (Global.player_game_data.max_unit_spawn == 15)
	_cap_huge.disabled = (Global.player_game_data.max_unit_spawn == 20)
	
	_autoplay_btn.text = "Autoplay : " + ("On" if Global.enable_autoplay else "Off") 
	
func _on_easy_btn_pressed():
	set_all_disabled()
	Global.player_game_data.ai_level = Global.AI_LEVEL[Global.EASY_AI]
	Global.player_game_data.ai_units = Global.generate_ai_units(Global.EASY_AI)
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_medium_pressed():
	set_all_disabled()
	Global.player_game_data.ai_level = Global.AI_LEVEL[Global.MEDIUM_AI]
	Global.player_game_data.ai_units = Global.generate_ai_units(Global.MEDIUM_AI)
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_hard_pressed():
	set_all_disabled()
	Global.player_game_data.ai_level = Global.AI_LEVEL[Global.HARD_AI]
	Global.player_game_data.ai_units = Global.generate_ai_units(Global.HARD_AI)
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_small_size_pressed():
	set_all_disabled()
	Global.player_game_data.max_unit_spawn = 10
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_medium_size_pressed():
	set_all_disabled()
	Global.player_game_data.max_unit_spawn = 15
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_huge_size_pressed():
	set_all_disabled()
	Global.player_game_data.max_unit_spawn = 20
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_autoplay_btn_pressed():
	Global.enable_autoplay = not Global.enable_autoplay
	apply_btn_condition()







