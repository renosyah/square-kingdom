extends HBoxContainer

signal pressed(data)
signal gone(node)

onready var _icon = $button/TextureRect
onready var _name = $button/PanelContainer/VBoxContainer/HBoxContainer/name
onready var _cost = $button/PanelContainer/VBoxContainer/cost
onready var _progress = $button/TextureProgress
onready var _hide = $button/hide
onready var _button = $button
onready var _panel = $button/PanelContainer
onready var _border = $button/border

onready var _cooldown = $cooldown
onready var _tween = $Tween
onready var _tween2 = $Tween2
onready var _audio = $AudioStreamPlayer


var data = {}
var is_clickable = false
var is_enable = true

var _is_clicked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_name.text = data.name
	_cost.text = str(data.cost)
	_icon.texture = load(data.icon)
	_progress.value = data.cooldown
	_progress.max_value = data.cooldown
	_panel.color = data.color
	_border.modulate = data.color
	
	rect_pivot_offset = rect_size / 2
	_tween.interpolate_property(self, "rect_scale", Vector2(-1, 1), Vector2.ONE, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
	cooldown()
	
func cooldown():
	_cooldown.wait_time = data.cooldown
	_cooldown.start()
	
func remove_card():
	set_process(false)
	rect_pivot_offset = rect_size / 2
	_tween2.interpolate_property(self, "rect_scale",Vector2.ONE, Vector2.ZERO, 0.4, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween2.start()
	
func _on_Tween_tween_completed(object, key):
	hide()
	emit_signal("gone", self)
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_hide.visible = not is_clickable
	modulate.a = 0.7 if not is_enable else 1.0
	_progress.max_value = data.cooldown
	_progress.value = _cooldown.time_left
	
func _on_button_pressed():
	if not _cooldown.is_stopped():
		_cant_click()
		return
		
	if not is_clickable or not is_enable:
		_cant_click()
		return
	
	if _is_clicked:
		_cant_click()
		return
		
	_is_clicked = true
	
	_audio.stream = preload("res://assets/sound/click.wav")
	_audio.play()

	remove_card()
	emit_signal("pressed", data)

func _cant_click():
	rect_pivot_offset = rect_size / 2
	_tween.interpolate_property(self, "rect_scale", Vector2(0.9, 0.9), Vector2.ONE, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
	_audio.stream = preload("res://assets/sound/assault_click.wav")
	_audio.play()






