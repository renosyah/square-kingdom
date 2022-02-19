extends Control

onready var _input_name = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/player_name_setting/input_name

onready var _team_1_color = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/HBoxContainer/team_1_setting/hbox/color
onready var _team_2_color = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/HBoxContainer/team_2_setting/hbox/color

onready var _color_picker = $CanvasLayer/Control/input_color

onready var _easy_button = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/ai_setting/easy_btn
onready var _medium_button = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/ai_setting/medium
onready var _hard_button = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/ai_setting/hard

onready var _map_small = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/map_setting/map_small_btn
onready var _map_normal = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/map_setting/map_normal_btn
onready var _map_large = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/map_setting/map_large_btn

onready var _cap_small = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/pop_cap/small_size
onready var _cap_medium = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/pop_cap/medium_size
onready var _cap_huge = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/pop_cap/huge_size

onready var _music = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/HBoxContainer2/team_1_setting/hbox/music
onready var _sfx = $CanvasLayer/Control/VBoxContainer2/ScrollContainer/VBoxContainer/HBoxContainer2/team_2_setting/hbox/sfx

# Called when the node enters the scene tree for the first time.
func _ready():
	set_current_setting()
	get_tree().set_quit_on_go_back(true)
	get_tree().set_auto_accept_quit(true)

func set_current_setting():
	_input_name.placeholder_text = Global.player_data.name
	
	_team_1_color.color = Global.player_game_data[Global.TEAM_1].color
	_team_2_color.color = Global.player_game_data[Global.TEAM_2].color
	
	apply_btn_condition()
	
func set_all_enable():
	_easy_button.disabled = false
	_medium_button.disabled = false
	_hard_button.disabled = false
	_map_small.disabled = false
	_map_normal.disabled = false
	_map_large.disabled = false
	_cap_small.disabled = false
	_cap_medium.disabled = false
	_cap_huge.disabled = false

func apply_btn_condition():
	_easy_button.disabled = (Global.player_game_data.ai_level.name == Global.EASY_AI)
	_medium_button.disabled = (Global.player_game_data.ai_level.name == Global.MEDIUM_AI)
	_hard_button.disabled = (Global.player_game_data.ai_level.name == Global.HARD_AI)
	_map_small.disabled =  (Global.player_game_data.map_size.name == Global.SMALL_SIZE.name)
	_map_normal.disabled = (Global.player_game_data.map_size.name == Global.NORMAL_SIZE.name)
	_map_large.disabled = (Global.player_game_data.map_size.name == Global.LARGE_SIZE.name)
	_cap_small.disabled = (Global.player_game_data.max_unit_spawn == 10)
	_cap_medium.disabled = (Global.player_game_data.max_unit_spawn == 15)
	_cap_huge.disabled = (Global.player_game_data.max_unit_spawn == 20)
	_music.text = "On" if Global.audio_setting.music else "Off"
	_sfx.text = "Enable" if Global.audio_setting.sfx else "Disable"

func _on_back_pressed():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")

func _on_save_name_pressed():
	if _input_name.text == "":
		return
		
	Global.player_data.name = _input_name.text
	Global.save_player_data()
	
func _on_team_1_randomize_color_pressed():
	_color_picker.visible = true
	clear_color_picker_signal()
	_color_picker.connect("on_pick", self, "_pick_for_team_1")
	
func _on_team_2_randomize_color_pressed():
	_color_picker.visible = true
	clear_color_picker_signal()
	_color_picker.connect("on_pick", self, "_pick_for_team_2")
	
func clear_color_picker_signal():
	for i in _color_picker.get_signal_connection_list("on_pick"):
		_color_picker.disconnect("on_pick", self, i.method)
		
func _pick_for_team_1(_color):
	_team_1_color.color = _color
	Global.player_game_data[Global.TEAM_1].color = _color

	for i in Global.player_game_data.buildings:
		if i.type_building == Buildings.TYPE_CASTLE and i.team == Global.TEAM_1:
			i.color = _color
		
	Global.save_player_game_data()
	
func _pick_for_team_2(_color):
	_team_2_color.color = _color
	Global.player_game_data[Global.TEAM_2].color = _color

	for i in Global.player_game_data.buildings:
		if i.type_building == Buildings.TYPE_CASTLE and i.team == Global.TEAM_2:
			i.color = _color
		
	Global.save_player_game_data()
	
func _on_easy_btn_pressed():
	set_all_enable()
	Global.player_game_data.ai_level = Global.AI_LEVEL[Global.EASY_AI]
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_medium_pressed():
	set_all_enable()
	Global.player_game_data.ai_level = Global.AI_LEVEL[Global.MEDIUM_AI]
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_hard_pressed():
	set_all_enable()
	Global.player_game_data.ai_level = Global.AI_LEVEL[Global.HARD_AI]
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_map_small_btn_pressed():
	set_all_enable()
	Global.player_game_data.map_size = Global.SMALL_SIZE
	Global.player_game_data = Global.generate_farm_and_tower(Global.player_game_data, 6, 4, 2)
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_map_normal_btn_pressed():
	set_all_enable()
	Global.player_game_data.map_size = Global.NORMAL_SIZE
	Global.player_game_data = Global.generate_farm_and_tower(Global.player_game_data, 8, 6, 4)
	apply_btn_condition()
	Global.save_player_game_data()

func _on_map_large_btn_pressed():
	set_all_enable()
	Global.player_game_data.map_size = Global.LARGE_SIZE
	Global.player_game_data = Global.generate_farm_and_tower(Global.player_game_data, 12, 8, 6)
	apply_btn_condition()
	Global.save_player_game_data()

func _on_small_size_pressed():
	set_all_enable()
	Global.player_game_data.max_unit_spawn = 10
	apply_btn_condition()
	Global.save_player_game_data()

func _on_medium_size_pressed():
	set_all_enable()
	Global.player_game_data.max_unit_spawn = 15
	apply_btn_condition()
	Global.save_player_game_data()

func _on_huge_size_pressed():
	set_all_enable()
	Global.player_game_data.max_unit_spawn = 20
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_music_pressed():
	Global.audio_setting.music = not Global.audio_setting.music
	Global.play_music()
	_music.text = "On" if Global.audio_setting.music else "Off"
	Global.save_audio_setting()
	
func _on_sfx_pressed():
	Global.audio_setting.sfx = not Global.audio_setting.sfx
	AudioServer.set_bus_mute(AudioServer.get_bus_index("sfx"),not Global.audio_setting.sfx) 
	_sfx.text = "Enable" if Global.audio_setting.sfx else "Disable"
	Global.save_audio_setting()  








