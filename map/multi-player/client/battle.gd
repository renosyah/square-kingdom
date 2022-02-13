extends BattleMP

onready var _ui = $ui
onready var _camera = $cameraPivot

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	_init_client()
	
################################################################
# init client player
func _init_client():
	.init_connection_watcher()
	_request_building_data(Global.client.network_unique_id)
	
################################################################
# camera
func _on_castle_spawn(_team, _translation):
	if _team != Global.player_data.team:
		return
		
	_camera.translation = _translation
	
################################################################
# grpc client func
func _request_building_data(from_id : int):
	rpc_id(Network.PLAYER_HOST_ID, "_request_building_data", from_id)
	
remote func _receive_building_data(_data : Dictionary):
	._receive_building_data(_data)
	
	if get_tree().is_network_server():
		return
		
	game_data = _data
	
	_spawn_buildings($castle_holder.get_path(), $farm_holder.get_path())
	
remotesync func _game_info(_flag : int, _data : Dictionary):
	if _data.has("message"):
		_ui.display_loading(_flag == GAME_LOADING, _data.message)
	
	if _flag == GAME_START:
		_ui.add_to_deck(_draw_card(MAX_DRAW_CARD, Global.player_data.team))
		
	elif _flag == GAME_INFO:
		pass
		
	elif _flag == GAME_OVER:
		pass
		
	elif _flag == GAME_FINISH:
		winner_team = _data.winner
		var is_win = winner_team == Global.player_data.team
		var condition = "Victory!" if is_win else "Defeat!"
		var message = "Our team win!" if is_win else "Our team lose!"
		_ui.display_game_over(condition, message)
		clear_entity()
	
func clear_entity():
	for i in $castle_holder.get_children() + $farm_holder.get_children() + $unit_holder.get_children():
		i.queue_free()
		
	$terrain.visible = false
	Network.disconnect_from_server()
	
################################################################
# update from ui and call update to ui
func on_coin_updated(_team : String , _amount : int):
	.on_coin_updated(_team, _amount)
	var team = Global.player_data.team
	
	if team != _team:
		return
		
	var pop = _number_of_unit_spawn($unit_holder,team)
	_ui.display_clickable_deck(pop, MAX_UNIT_SPAWN, _amount)
	_ui.display_coin(_amount)
	
	
	
func _on_capture_progress(_building, _capture_by, _cp_damage, _cp, _max_cp):
	._on_capture_progress(_building, _capture_by, _cp_damage, _cp, _max_cp)
	if _building.type_building != Buildings.TYPE_CASTLE:
		return
		
	_ui.display_hurt(_building.team)
	
	
	
func on_building_captured(_building,_last_owner_team,_capture_by):
	.on_building_captured(_building,_last_owner_team,_capture_by)
	var building = _building.building_name
	var message = ""
	var team = Global.player_data.team
	
	# owner and by who
	if _capture_by == team and _last_owner_team == "":
		message = building + " Seized!"
		
	if _capture_by == team and _last_owner_team != "":
		message = building + " is Captured!"
		
	if _capture_by != team and _last_owner_team == team:
		message = "We have lost a " + building + "!"
		
	if message == "":
		return
		
	_ui.display_info(message)
	
	
	
func _on_ui_on_deploy_card(unit):
	rpc_id(Network.PLAYER_HOST_ID, "_deploy_card", unit)
	_ui.add_to_deck(_draw_card(1, unit.team))
	
func _unit_spawned():
	._unit_spawned()
	var team = Global.player_data.team
	var coin = game_data[team].coin
	var pop = _number_of_unit_spawn($unit_holder,team)
	_ui.display_population(team, pop, MAX_UNIT_SPAWN)
	_ui.display_clickable_deck(pop, MAX_UNIT_SPAWN, coin)








