extends Control

signal on_pick_color_press(_method_target)
signal code_redeem

onready var _input_name = $VBoxContainer/player_name_setting/input_name

onready var _team_1_color = $VBoxContainer/HBoxContainer/team_1_setting/hbox/color
onready var _team_2_color = $VBoxContainer/HBoxContainer/team_2_setting/hbox/color

# Called when the node enters the scene tree for the first time.
func _ready():
	_input_name.placeholder_text = Global.player_data.name
	_input_name.text = Global.player_data.name
	
	_team_1_color.color = Global.player_game_data[Global.TEAM_1].color
	_team_2_color.color = Global.player_game_data[Global.TEAM_2].color


func _on_save_name_pressed():
	if _input_name.text == "":
		return
		
	Global.player_data.name = _input_name.text
	Global.save_player_data()
	
	if Global.check_player_name():
		emit_signal("code_redeem")

func _on_team_1_randomize_color_pressed():
	emit_signal("on_pick_color_press","_pick_for_team_1")


func _on_team_2_randomize_color_pressed():
	emit_signal("on_pick_color_press","_pick_for_team_2")


func _pick_for_team_1(_color):
	_team_1_color.color = _color
	Global.player_game_data[Global.TEAM_1].color = _color
	
	for i in Global.player_game_data.buildings:
		if i.type_building == Buildings.TYPE_CASTLE and i.team == Global.TEAM_1:
			i.color = _color
		
	Global.save_player_game_data()
	
	# for player
	Global.player_data.color = Global.player_game_data[Global.TEAM_1].color
	Global.apply_players_unit_team()
	Global.save_player_data()
	
	Global.apply_players_unit_inventories()
	Global.save_player_inventories()
	
func _pick_for_team_2(_color):
	_team_2_color.color = _color
	Global.player_game_data[Global.TEAM_2].color = _color

	for i in Global.player_game_data.buildings:
		if i.type_building == Buildings.TYPE_CASTLE and i.team == Global.TEAM_2:
			i.color = _color
		
	Global.save_player_game_data()
	
	
	
	
