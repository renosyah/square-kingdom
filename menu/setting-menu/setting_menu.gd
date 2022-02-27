extends Control

onready var _game_setting = $CanvasLayer/Control/VBoxContainer2/game_setting
onready var _map_setting = $CanvasLayer/Control/VBoxContainer2/map_setting
onready var _tag_setting = $CanvasLayer/Control/VBoxContainer2/tag_setting
onready var _audio_setting = $CanvasLayer/Control/VBoxContainer2/audio_setting

onready var _color_picker = $CanvasLayer/input_color

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	_on_tag_pressed()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_back_pressed()
			return
		
func _on_back_pressed():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")

func all_hide():
	_game_setting.visible = false
	_map_setting.visible = false
	_tag_setting.visible = false
	_audio_setting.visible = false

func _on_tag_pressed():
	all_hide()
	_tag_setting.visible = true

func _on_map_pressed():
	all_hide()
	_map_setting.visible = true

func _on_audio_pressed():
	all_hide()
	_audio_setting.visible = true

func _on_game_pressed():
	all_hide()
	_game_setting.visible = true


func _on_tag_setting_on_pick_color_press(_method_target):
	clear_color_picker_signal()
	_color_picker.connect("on_pick", _tag_setting, _method_target)
	_color_picker.visible = true
	

func clear_color_picker_signal():
	for i in _color_picker.get_signal_connection_list("on_pick"):
		_color_picker.disconnect("on_pick", _tag_setting, i.method)
	
	
	
	
	
	
