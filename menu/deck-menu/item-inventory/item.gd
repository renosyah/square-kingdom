extends Control

signal add_card(_node, _data)
signal on_click(_node, _data)

onready var _icon = $TextureRect
onready var _name = $PanelContainer/VBoxContainer/name
onready var _cost = $PanelContainer/VBoxContainer/cost
onready var _panel = $PanelContainer
onready var _border = $border

onready var _hide = $hide
onready var _add_card_button = $add_card
onready var _is_new = $is_new

onready var _input_detection = $input_detection

var data = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_name.text = data.name
	_cost.text = str(data.cost)
	_icon.texture = load(data.icon)
	_panel.color = data.color
	_border.modulate = data.color
	
	_add_card_button.visible = false
	_is_new.visible = false
	_hide.visible = false
	
	if data.has("FLAG"):
		_hide.visible = (data["FLAG"] == Global.FLAG_UNIT_LOCKED)
		_is_new.visible = (data["FLAG"] == Global.FLAG_UNIT_UNLOCKED)
		
func show_add_button():
	if data.has("FLAG"):
		_add_card_button.visible = data["FLAG"] != Global.FLAG_UNIT_LOCKED
		return
		
	_add_card_button.visible = true
	
func _on_add_card_pressed():
	if data.has("FLAG"):
		data.erase("FLAG")
		_ready()
		
	emit_signal("add_card", self, data)
	
	
func _on_item_gui_input(event):
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		emit_signal("on_click", self, data)
		
	_input_detection.check_input(event)
	
	
func _on_input_detection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_click", self, data)



