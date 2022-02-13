extends Control

signal kick(_data)

onready var _name = $Panel/HBoxContainer/VBoxContainer/player_name
onready var _status = $Panel/HBoxContainer/VBoxContainer/Label
onready var _color = $Panel/HBoxContainer/team_color
onready var _kick_btn = $Panel/HBoxContainer/panel

var can_kick = false
var data = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_name.text = data.name
	_color.color = data.color
	_status.text = data.status
	_kick_btn.visible = can_kick

func _on_kick_player_pressed():
	emit_signal("kick",data)
