extends Control

onready var _colors = [$VBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/color2, $VBoxContainer/HBoxContainer/Panel/VBoxContainer/Control/color]
onready var _icon = $VBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/color2/icon
onready var _name = $VBoxContainer/HBoxContainer/Panel/VBoxContainer/Control/HBoxContainer3/name
onready var _attack = $VBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer/atk/attack
onready var _cap = $VBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer/cap/cap
onready var _hp = $VBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer/hp/hp
onready var _speed = $VBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer/speed/speed
onready var _cost = $VBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer/cost/cost

func _ready():
	pass
	
func display_detail(data):
	for _color in _colors:
		_color.color = data.color
		_color.color.a = 0.8
		
	_icon.texture = load(data.icon)
	_name.text = data.name
	_attack.text = str(round(data.attack_damage) * round(data.attack_cooldown)) + " dmg/s"
	_cap.text = str(round(data.capture_damage) * round(data.attack_cooldown)) + " dmg/s"
	_hp.text = str(round(data.max_hp)) + " hp"
	_speed.text = str(round(data.speed)) + " mtr/s"
	_cost.text = str(round(data.cost)) + " coin"
	
func _on_close_pressed():
	visible = false
