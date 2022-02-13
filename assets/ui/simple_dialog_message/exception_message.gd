extends Control

onready var _title = $Panel/VBoxContainer/HBoxContainer3/Label
onready var _message = $Panel/VBoxContainer/HBoxContainer2/message

func display_message(title, message : String):
	_title.text = title
	_message.text = message
	
func _on_close_exeption_message_pressed():
	visible = false
