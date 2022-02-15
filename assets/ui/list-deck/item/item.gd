extends Control

signal pressed(data)
signal gone(node)

onready var _icon = $HBoxContainer/button/TextureRect
onready var _name = $HBoxContainer/button/PanelContainer/VBoxContainer/name
onready var _cost = $HBoxContainer/button/PanelContainer/VBoxContainer/cost
onready var _progress = $HBoxContainer/button/TextureProgress
onready var _hide = $HBoxContainer/button/hide
onready var _button = $HBoxContainer/button
onready var _panel = $HBoxContainer/button/PanelContainer
onready var _border = $HBoxContainer/button/border

onready var _content = $HBoxContainer

onready var _cooldown = $cooldown
onready var _tween = $Tween
onready var _tween2 = $Tween2
onready var _audio = $AudioStreamPlayer


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
	
	_content.rect_pivot_offset = _content.rect_size / 2
	_tween.interpolate_property(_content, "rect_scale", Vector2.ZERO, Vector2.ONE, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
	cooldown()
	
func cooldown():
	_cooldown.wait_time = data.cooldown
	_cooldown.start()
	
func remove_card():
	_content.rect_pivot_offset = _content.rect_size / 2
	_tween2.interpolate_property(_content, "rect_scale",Vector2.ONE, Vector2.ZERO, 0.4, Tween.TRANS_SINE, Tween.EASE_IN)
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
		_cant_click()
		return
		
	if not is_clickable or not is_enable:
		_cant_click()
		return
		
	is_clickable = false
	_audio.stream = preload("res://assets/sound/click.wav")
	_audio.play()
	
	remove_card()
	emit_signal("pressed", data)

func _cant_click():
	_content.rect_pivot_offset = _content.rect_size / 2
	_tween.interpolate_property(_content, "rect_scale", Vector2(0.9, 0.9), Vector2.ONE, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
	_audio.stream = preload("res://assets/sound/assault_click.wav")
	_audio.play()






