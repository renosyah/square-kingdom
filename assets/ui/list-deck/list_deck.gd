extends VBoxContainer

signal on_item_press(data)

onready var _container = $HBoxContainer
onready var min_size = rect_size

func update_list_clickable_by_cost(_clickable : bool, _coin_amount : int = 0):
	if _container.get_children().empty():
		return
		
	for i in _container.get_children():
		i.is_clickable = _clickable and (_coin_amount >= i.data.cost)
		
func update_list_enable(_is_enable : bool):
	if _container.get_children().empty():
		return
		
	for i in _container.get_children():
		i.is_enable = _is_enable
		
func clear_list():
	for i in _container.get_children():
		i.queue_free() 
		
func update_list(_datas : Array):
	for i in _datas:
		var item = preload("res://assets/ui/list-deck/item/item.tscn").instance()
		item.connect("pressed", self, "_pressed")
		item.connect("gone", self, "_item_gone")
		item.data = i
		_container.add_child(item)
	
func _pressed(data):
	emit_signal("on_item_press", data)
	
func _item_gone(item):
	rect_size = min_size





