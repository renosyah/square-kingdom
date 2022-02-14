extends HBoxContainer

signal pressed(data)
signal gone(node)

onready var _icon = $button/TextureRect
onready var _name = $button/PanelContainer/VBoxContainer/name
onready var _cost = $button/PanelContainer/VBoxContainer/cost
onready var _cooldown = $cooldown
onready var _progress = $button/TextureProgress
onready var _hide = $button/hide
onready var _button = $button
onready var _tween = $Tween
onready var _tween2 = $Tween2
onready var _panel = $button/PanelContainer
onready var _border = $button/border

var data = {}
var is_clickable = false
var is_enable = true

# Called when the node enters the scene tree for the first time.
func _ready():
	_name.text = data.name
	_cost.text = str(data.cost)
	_icon.texture = load(data.icon)
	_progress.value = data.cooldown
	_progress.max_value = data.cooldown
	_panel.color = data.color
	_border.modulate = data.color
	
	rect_scale.y = 0
	_tween.interpolate_property(self, "rect_scale:y", rect_scale.y, 1, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
	cooldown()
	
func cooldown():
	_cooldown.wait_time = data.cooldown
	_cooldown.start()
	
func remove_card():
	_tween2.interpolate_property(self, "rect_scale:x", 1, 0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween2.start()
	
func _on_Tween_tween_completed(object, key):
	hide()
	emit_signal("gone", self)
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_hide.visible = not is_clickable
	modulate.a = 0.5 if not is_enable else 1.0
	_progress.max_value = data.cooldown
	_progress.value = _cooldown.time_left
	
func _on_button_pressed():
	if not _cooldown.is_stopped():
		return
		
	if not is_clickable or not is_enable:
		return
		
	is_clickable = false
	
	remove_card()
	emit_signal("pressed", data)



