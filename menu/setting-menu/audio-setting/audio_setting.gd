extends Control

onready var _music = $VBoxContainer/HBoxContainer2/music/hbox/music
onready var _sfx = $VBoxContainer/HBoxContainer2/sfx/hbox/sfx


# Called when the node enters the scene tree for the first time.
func _ready():
	_music.text = "On" if Global.audio_setting.music else "Off"
	_sfx.text = "Enable" if Global.audio_setting.sfx else "Disable"


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
