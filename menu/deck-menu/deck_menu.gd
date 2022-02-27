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
onready var _detail = $CanvasLayer/item_detail

var decks = []
var inventories = []

class CardSorter:
	static func sort(a, b):
		if a["cost"] < b["cost"]:
			return true
		return false
		
		
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	decks = Global.player_data.units.duplicate()
	inventories = Global.player_inventories.duplicate()
	apply_color()
	refill_holder()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_back_pressed()
			return
			
func apply_color():
	Global.player_data.color = Global.player_game_data[Global.TEAM_1].color
	Global.apply_players_unit_team()
	Global.save_player_data()
	
	Global.apply_players_unit_inventories()
	Global.save_player_inventories()
	
func refill_holder():
	empty_holder(_deck_holder)
	empty_holder(_inventory_holder)
	
	decks.sort_custom(CardSorter, "sort")
	inventories.sort_custom(CardSorter, "sort")
	
	for i in decks:
		var item = card_deck.instance()
		item.data = i
		item.connect("remove_card", self, "_on_remove_card_from_deck")
		item.connect("on_click", self ,"_on_card_click")
		_deck_holder.add_child(item)
		
	for i in inventories:
		var item = card_inventory.instance()
		item.data = i
		item.connect("add_card", self, "_on_add_card_to_deck")
		item.connect("on_click", self ,"_on_card_click")
		_inventory_holder.add_child(item)
		item.show_add_button()
		
	var total_unlock = 0
	for i in inventories:
		if i.has("FLAG"):
			if i["FLAG"] == Global.FLAG_UNIT_UNLOCKED:
				total_unlock += 1
		else:
			total_unlock += 1
		
	_deck_button.text = "Deck (8/{count})".format({"count": decks.size()})
	_inventory_button.text = "Inventory ({count}/{total})".format({"count":total_unlock,"total": inventories.size()})
	
	
func empty_holder(_node):
	for i in _node.get_children():
		_node.remove_child(i)
	
func _on_card_click(_node, _data):
	_detail.display_detail(_data)
	_detail.visible = true
	
func _on_remove_card_from_deck(_node, _data):
	decks.erase(_data)
	inventories.append(_data)
	refill_holder()
	
func _on_add_card_to_deck(_node, _data):
	decks.append(_data)
	inventories.erase(_data)
	refill_holder()
	
func _on_test_unlock_pressed():
	var cards = Global.unlock_random_card_in_inventory()
	for i in cards:
		print(i.name)
		
	get_tree().reload_current_scene()
	
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













