extends Node
class_name BattleMP

const CAMERA_HEIGHT = 10
const CINEMATICS = [
	# sides
	{
		start = Vector3(-25, CAMERA_HEIGHT, 0),
		end = Vector3(25, CAMERA_HEIGHT, 0),
	},
	{
		start = Vector3(25, CAMERA_HEIGHT, 0),
		end = Vector3(-25, CAMERA_HEIGHT, 0),
	},
	# tops bottom
	{
		start = Vector3(0, CAMERA_HEIGHT, -25),
		end = Vector3(0, CAMERA_HEIGHT, 25),
	},
	{
		start = Vector3(0, CAMERA_HEIGHT, 25),
		end = Vector3(0, CAMERA_HEIGHT, -25),
	},
	# tops side to botton side
	{
		start = Vector3(-25, CAMERA_HEIGHT, -25),
		end = Vector3(25, CAMERA_HEIGHT, 25),
	},
	{
		start = Vector3(25, CAMERA_HEIGHT, 25),
		end = Vector3(-25, CAMERA_HEIGHT, -25),
	},
	{
		start = Vector3(25, CAMERA_HEIGHT, 25),
		end = Vector3(-25, CAMERA_HEIGHT, -25),
	},
	{
		start = Vector3(25, CAMERA_HEIGHT, -25),
		end = Vector3(-25, CAMERA_HEIGHT, 25),
	}
]

const MIN_FARM_AQUIRE = 2
const MAX_CASTLE_PRODUCING = 50
const MAX_DRAW_CARD = 3

const GAME_LOADING = 0
const GAME_START = 1
const GAME_INFO = 2
const GAME_OVER = 3
const GAME_FINISH = 4

var MAX_UNIT_SPAWN = 10
# data match each team
var game_data = {
	Global.TEAM_1 : {
		team_name = "",
		color = Color.blue,
		coin = 100,
		units = [],
	},
	Global.TEAM_2 : {
		team_name = "",
		color = Color.red,
		coin = 100,
		units = [],
	},
	buildings = [],
	map_size = {}
}

# spawned object
var castles = {
	Global.TEAM_1 : null,
	Global.TEAM_2 : null
}

################################################################
# server variables
var game_flag = GAME_LOADING
var winner_team = ""
var units = []
var farms = []

var closes_farm = {
	Global.TEAM_1 : [],
	Global.TEAM_2 : []
}

# {player : {}, unit_deploy : 0, unit_kill : 0, unit_lost: 0, building_own: 0 }
var scores = {}

################################################################

func _ready():
	Global.apply_players_unit_team()
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)

################################################################
# network connection watcher
# for both client and host
func init_connection_watcher():
	Network.connect("server_disconnected", self , "_server_disconnected")
	Network.connect("connection_closed", self , "_connection_closed")
	
	# if some player decide or happen to be disconect
	Network.connect("player_disconnected", self, "_on_player_disconnected")
	Network.connect("receive_player_info", self,"_on_receive_player_info")
	
func _on_player_disconnected(_player_network_unique_id : int):
	Network.request_player_info(_player_network_unique_id)
	
func _on_receive_player_info(_player_network_unique_id : int, data : Dictionary):
	on_player_disynchronize(data["name"])
	
func on_player_disynchronize(_player_name : String):
	pass
	
func _server_disconnected():
	Global.mp_exception_message = "Unexpected exit by Server!"
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
func _connection_closed():
	print("exit by Client!")
	
################################################################
func _player_draw_card(_cards : Array, quantity : int) -> Array:
	var cards = []
		
	if _cards.empty():
		return []
		
	for i in quantity:
		cards.append(_draw_a_card(_cards))
	
	return cards
	
func _draw_a_card(_cards) -> Dictionary:
	_cards.shuffle()
	for unit in _cards:
		if unit.is_draw:
			continue
			
		unit.is_draw = true
		return unit.duplicate()
		
	return {}
		
func _player_deploy_card(_unit : Dictionary, _cards : Array):
		for i in _cards:
			if i.id == _unit.id:
				i.is_draw = false
				break
	
	
func _ai_draw_card(quantity : int) -> Array:
	var cards = []
	for i in quantity:
		var unit = game_data.ai_units[randi() % game_data.ai_units.size()]
		cards.append(unit.duplicate())
		
	return cards
	
# deploy card
remote func _deploy_card(_player: Dictionary, _unit : Dictionary):
	if not get_tree().is_network_server():
		return
		
	var team = _unit.team
	if game_data[team].coin - _unit.cost < 0:
		return
		
	game_data[team].coin -= _unit.cost
	_unit.node_name = "UNIT-" + GDUUID.v4()
	_unit.translation = castles[team].translation
	
	# apply buff
	for _building in farms:
		if _building.type_building == Buildings.TYPE_UNIT_BUFF and _building.team == team:
			_building.apply_upgrade(_unit)
			
			
	rpc("_on_coin_updated", _get_coin_each_team())
	rpc("_spawn_unit", $unit_holder.get_path(), _player, _unit)
	
################################################################
# host broadcast about game status
# _flag = 0 on going, 1 game statrter, 2 mid game information, 3 game over
# _data = { winer : "team" , message : "red team win", coin_owned = 0, farm_owned = 0, tower_owned = 0}
remotesync func _game_info(
	_flag : int,
	_data : Dictionary
):
	pass
################################################################
# spawning buildings
func _spawn_buildings(castle_holder : NodePath, farm_holder : NodePath):
	var _castle_holder = get_node_or_null(castle_holder)
	if not is_instance_valid(_castle_holder):
		return
		
	var _farm_holder = get_node_or_null(farm_holder)
	if not is_instance_valid(_farm_holder):
		return
	
	for i in _castle_holder.get_children() + _farm_holder.get_children():
		i.queue_free()

	for i in game_data.buildings:
		var building = load(i.scene).instance()
		building.player = {}
		building.name = i.node_name
		building.set_network_master(Network.PLAYER_HOST_ID)
		building.set_data(i)
		building.translation = i.translation
		building.translation.y = 0.0
		building.connect("on_ready", self, "_on_building_ready")
		building.connect("on_building_captured", self, "_on_building_captured")
		building.connect("on_capture_progress", self, "_on_capture_progress")
		
		if i.type_building != Buildings.TYPE_UNIT_BUFF:
			building.connect("on_coin_produce", self,"_on_coin_produce")
		
		if i.type_building == Buildings.TYPE_CASTLE:
			castles[i.team] = building
			_castle_holder.add_child(building)
			
		else:
			if get_tree().is_network_server():
				farms.append(building)
				
			_farm_holder.add_child(building)
			
	_make_list_closes_farm()
	
	
	
func _on_building_ready(_building):
	pass
	
	
func _on_building_captured(_building):
	on_building_captured(_building, _building.last_owner_team, _building.team)
	
	if not get_tree().is_network_server():
		return
		
	# player,unit_deploy, unit_kill, unit_lost, building_own
	update_scores(_building.capture_by.player, 0, 0, 0 , 1)
	
	if _building.type_building == Buildings.TYPE_FARM:
		if castles[_building.team].amount >= MAX_CASTLE_PRODUCING:
			return
			
		var _current_amount = castles[_building.team].amount
		castles[_building.team].update_amount(_current_amount + _building.amount)
		
	elif _building.type_building == Buildings.TYPE_CASTLE:
		
		if _building.team == "":
			return
			
		if _building.last_owner_team == "":
			return
			
		# winner is set
		winner_team = _building.team
		game_flag = GAME_OVER
		
		rpc("_game_info",  game_flag , { message =  "", "scores" : scores })
	
func _on_capture_progress(_building, _capture_by, _cp_damage, _cp, _max_cp):
	pass
	
func on_building_captured(_building,_last_owner_team,capture_by):
	pass
	
	
################################################################
# coin obtain
func _on_coin_produce(_team : String, _amount : int):
	if not get_tree().is_network_server():
		return
		
	if _team == "":
		return
		
	if game_data[_team].coin > 999:
		return
		
	if game_flag != GAME_START:
		return
		
	game_data[_team].coin += _amount

remotesync func _on_coin_updated(_coin_update : Dictionary):
	for i in _coin_update.keys():
		on_coin_updated(i, _coin_update[i])
	
func on_coin_updated(_team : String , _amount : int):
	game_data[_team].coin = _amount
	
################################################################
# spawning units
remotesync func _spawn_unit(unit_holder : NodePath, _player: Dictionary, _unit : Dictionary):
	var _unit_holder = get_node_or_null(unit_holder)
	if not is_instance_valid(_unit_holder):
		return
		
	var unit = load(_unit.scene).instance()
	unit.name = _unit.node_name
	unit.player = _player
	unit.set_network_master(Network.PLAYER_HOST_ID)
	unit.translation = _unit.translation
	unit.set_data(_unit)
	unit.connect("on_ready", self, "_on_unit_ready")
	unit.connect("on_dead", self, "_on_unit_dead")
	unit.connect("on_take_damage", self, "_on_unit_take_damage")
	_unit_holder.add_child(unit)
	
	if not _player.empty():
		# siplay if not from local player and is not bot
		unit.display_player_name(_player.id != Global.player_data.id and not _player.has("is_bot"))
	
	if get_tree().is_network_server():
		units.append(unit)
		
	_unit_spawned(unit)
	
func _on_unit_ready(_unit):
	if not get_tree().is_network_server():
		return
		
	_assign_unit_target(_unit)
		
	
func _on_unit_take_damage(_unit, _hit_by, _damage, _hp, _max_hp):
	pass
	
func _on_unit_dead(_unit):
	if get_tree().is_network_server():
		# player,unit_deploy, unit_kill, unit_lost, building_own
		update_scores(_unit.hit_by.player, 0, 1, 0 , 0)
		update_scores(_unit.player, 0, 0, 1 , 0)
		units.erase(units)
		
	_unit.queue_free()
	
func _unit_spawned(_unit):
	
	# player,unit_deploy, unit_kill, unit_lost, building_own
	update_scores(_unit.player, 1, 0, 0 , 0)
	
################################################################
# targeting assigment
class ClosesFarmShorter:
	static func sort(a, b):
		if a["distance"] < b["distance"]:
			return true
		return false
		
		
func _make_list_closes_farm():
	for key in closes_farm.keys():
		var arr = []
		for farm in farms:
			var obj = {
				"node" : farm,
				"distance" : farm.global_transform.origin.distance_to(castles[key].global_transform.origin)
			}
			arr.append(obj)
			
		closes_farm[key] = arr
		closes_farm[key].sort_custom(ClosesFarmShorter, "sort")
	
func _get_list_closes_farm_target(team : String) -> Array:
	var farms = []
	for i in closes_farm[team]:
		if i["node"].team != team:
			farms.append(i["node"])
		
	return farms
	
func _assign_unit_target(_unit):
	var farm_owned = _number_of_farm_owned(_unit.team)
	var targets = []

	if farm_owned >= MIN_FARM_AQUIRE:
		targets += units.duplicate()
		
	if farm_owned == farms.size():
		targets += castles.values().duplicate()
		
	targets.shuffle()
	targets = _get_list_closes_farm_target(_unit.team) + targets
	
	var target = null
	var team = _unit.team
	
	for i in targets:
		if not is_instance_valid(i):
			continue
			
		if randf() < 0.5:
			continue
			
		if i.team != team:
			target = i
			break
			
	if not is_instance_valid(target):
		return
		
	_unit.set_target(target.get_path())
	
################################################################
# utils function
func update_scores(player : Dictionary, unit_deploy, unit_kill, unit_lost, building_captured : int = 0):
	if not get_tree().is_network_server():
		return
		
	if game_flag == GAME_OVER:
		return
		
	if player.empty():
		return
		
	if not scores.has(player.id):
		scores[player.id] = {
			"team" : player.color,
			"player_name" : player.name,
			"unit_deploy" : 0,
			"unit_kill" : 0,
			"unit_lost": 0,
			"building_captured": 0,
			"total" : 0
		}
		
	var prev_score = scores[player.id].duplicate()
	prev_score.unit_deploy += unit_deploy
	prev_score.unit_kill += unit_kill
	prev_score.unit_lost += unit_lost
	prev_score.building_captured += building_captured
	
	prev_score.total = prev_score.unit_deploy + prev_score.unit_kill - prev_score.unit_lost
	
	scores[player.id] = prev_score
	
func _number_of_farm_owned(team) -> int:
	var farm_own = 0
	if not get_tree().is_network_server():
		return farm_own
		
	for i in farms:
		if i.team == team:
			farm_own += 1
	return farm_own
	
func _number_of_unit_spawn(holder, team) -> int:
	var unit_count = 0
	for i in holder.get_children():
		if not is_instance_valid(i):
			continue
			
		if i.is_dead:
			continue
			
		if i.team == team:
			unit_count += 1
			
	return unit_count
	
func _building_captured_title(_building_name, _team,_capture_by, _last_owner_team) -> String:
	if _capture_by == _team and _last_owner_team == "":
		return _building_name + " Seized!"
		
	if _capture_by == _team and _last_owner_team != "":
		return _building_name + " is Captured!"
		
	if _capture_by != _team and _last_owner_team == _team:
		return "We have lost a " + _building_name + "!"
		
	return ""
	
func _building_captured_message(_building, _team,_capture_by, _last_owner_team) -> String:
	if _building.type_building == Buildings.TYPE_FARM:
		if _capture_by == _team and _last_owner_team == "":
			return "+" + str(_building.amount) + " of Income"
			
		if _capture_by == _team and _last_owner_team != "":
			return "+" + str(_building.amount) + " of Income"
			
		if _capture_by != _team and _last_owner_team == _team:
			return "-" + str(_building.amount) + " of Income"
			
	elif _building.type_building == Buildings.TYPE_TOWER:
		if _capture_by == _team and _last_owner_team == "":
			return "+" + str(int(_building.attack_damage)) + " of Defence"
			
		if _capture_by == _team and _last_owner_team != "":
			return "+" + str(int(_building.attack_damage)) + " of Defence"
			
		if _capture_by != _team and _last_owner_team == _team:
			return "-" + str(int(_building.attack_damage)) + " of Defence"
			
	elif _building.type_building == Buildings.TYPE_UNIT_BUFF:
		if _capture_by == _team and _last_owner_team == "":
			return "+" + _building.upgrade_to_text()
			
		if _capture_by == _team and _last_owner_team != "":
			return "+" + _building.upgrade_to_text()
			
		if _capture_by != _team and _last_owner_team == _team:
			return "-" + _building.upgrade_to_text() + ""
			
	elif _building.type_building == Buildings.TYPE_CASTLE:
		if _capture_by == _team and _last_owner_team != "":
			return "Enemy castle has fallen into our hand!"
			
		if _capture_by != _team and _last_owner_team == _team:
			return "Your team's castle has fallen into enemy hand!"
			
	return ""
	
func _get_coin_each_team() -> Dictionary:
	var data = {}
	for i in Global.TEAMS:
		data[i] = game_data[i].coin
		
	return data
	
func _get_building_own_each_team(_castle_holder, _farm_holder : NodePath) -> Dictionary:
	var data = {
		Global.TEAM_1 : { "building" : 0, "color" : game_data[Global.TEAM_1].color },
		Global.TEAM_2 : { "building" : 0, "color" : game_data[Global.TEAM_2].color }
	}
	
	var _farms = get_node_or_null(_farm_holder)
	if not is_instance_valid(_farms):
		return data
		
	var _castles = get_node_or_null(_castle_holder)
	if not is_instance_valid(_castles):
		return data
		
	for team in data.keys():
		for f in _castles.get_children():
			if f.team == team:
				data[team].building += 1
				
		for f in _farms.get_children():
			if f.team == team:
				data[team].building += 1
				
	return data







