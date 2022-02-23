extends Control

signal remove_card(_node, _data)

onready var _icon = $TextureRect
onready var _name = $PanelContainer/VBoxContainer/name
onready var _cost = $PanelContainer/VBoxContainer/cost
onready var _panel = $PanelContainer
onready var _border = $border

var data = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_name.text = data.name
	_cost.text = str(data.cost)
	_icon.texture = load(data.icon)
	_panel.color = data.color
	_border.modulate = data.color

func _on_remove_card_pressed():
	emit_signal("remove_card", self, data)

