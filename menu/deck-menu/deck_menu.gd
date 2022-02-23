extends Control

const card_deck = preload("res://menu/deck-menu/item-deck/item.tscn")
const card_inventory = preload("res://menu/deck-menu/item-inventory/item.tscn")

onready var _deck_button = $CanvasLayer/Control/VBoxContainer2/HBoxContainer/deck
onready var _inventory_button = $CanvasLayer/Control/VBoxContainer2/HBoxContainer/inv

onready var _deck_layout = $CanvasLayer/Control/VBoxContainer2/deck_layout
onready var _inventory_layout = $CanvasLayer/Control/VBoxContainer2/inventory_layout

onready var _deck_holder = $CanvasLayer/Control/VBoxContainer2/deck_layout/VBoxContainer
onready var _inventory_holder = $CanvasLayer/Control/VBoxContainer2/inventory_layout/VBoxContainer

onready var _exception_message = $CanvasLayer/exception_message

var decks = []
var inventories = []

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	decks = Global.player_data.units.duplicate()
	inventories = Global.player_inventories.duplicate()
	refill_holder()
	
func refill_holder():
	empty_holder(_deck_holder)
	empty_holder(_inventory_holder)
	
	for i in decks:
		var item = card_deck.instance()
		item.data = i
		item.connect("remove_card", self, "_on_remove_card_from_deck")
		_deck_holder.add_child(item)
		
	for i in inventories:
		var item = card_inventory.instance()
		item.data = i
		item.connect("add_card", self, "_on_add_card_to_deck")
		_inventory_holder.add_child(item)
		
	_deck_button.text = "Deck ({count}/8)".format({"count": decks.size()})
	_inventory_button.text = "Inventory ({count})".format({"count": inventories.size()})
	
	
func empty_holder(_node):
	for i in _node.get_children():
		_node.remove_child(i)

func _on_remove_card_from_deck(_node, _data):
	decks.erase(_data)
	inventories.append(_data)
	refill_holder()
	
func _on_add_card_to_deck(_node, _data):
	decks.append(_data)
	inventories.erase(_data)
	refill_holder()
	
func _on_back_pressed():
	if decks.size() < 8:
		_exception_message.display_message("Invalid Deck", "Please add more card to your deck!")
		_exception_message.visible = true
		return
		
	Global.player_data.units = decks
	Global.player_inventories = inventories
	Global.save_player_data()
	Global.save_player_inventories()
	
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
func _on_deck_pressed():
	_deck_layout.visible = true
	_inventory_layout.visible = false
	
func _on_inv_pressed():
	_deck_layout.visible = false
	_inventory_layout.visible = true










