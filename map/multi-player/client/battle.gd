extends BattleMP

onready var _ui = $ui
onready var _camera = $cameraPivot
onready var _terrain = $terrain

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	_init_client()
	
################################################################
# init client player
func _init_client():
	.init_connection_watcher()
	_set_on_restart_match()
	
	game_data = Global.mp_game_data.duplicate(true)
	MAX_UNIT_SPAWN = game_data.max_unit_spawn
	_unit_spawned()
	
	_terrain.map_size = game_data.map_size
	_terrain.generate()
	
	_spawn_buildings($castle_holder.get_path(), $farm_holder.get_path())
	
################################################################
# camera
func _on_castle_spawn(_team, _translation):
	if _team != Global.player_data.team:
		return
		
	_camera.translation = _translation
	
################################################################
# grpc client func
remotesync func _game_info(_flag : int, _data : Dictionary):
	if _data.has("message"):
		_ui.display_loading(_flag == GAME_LOADING, _data.message)
	
	if _flag == GAME_START:
		_ui.add_to_deck(._player_draw_card(Global.player_data.units, MAX_DRAW_CARD))
		
	elif _flag == GAME_INFO:
		pass
		
	elif _flag == GAME_OVER:
		pass
		
	elif _flag == GAME_FINISH:
		winner_team = _data.winner
		var is_win = winner_team == Global.player_data.team
		var condition = "Victory!" if is_win else "Defeat!"
		var message = "Our team win!" if is_win else "Our team lose!"
		_ui.display_game_over(false, condition, message)
		clear_entity()
	
func clear_entity():
	for i in $castle_holder.get_children() + $farm_holder.get_children() + $unit_holder.get_children():
		i.queue_free()
		
	$terrain.visible = false
	
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
	var title = _building_captured_title(_building.building_name,Global.player_data.team,_capture_by,_last_owner_team)
	var message = _building_captured_message(_building,Global.player_data.team,_capture_by,_last_owner_team)
	if message == "" or title == "":
		return

	_ui.display_info(title, message)
	
	
	
func _on_ui_on_deploy_card(unit):
	rpc_id(Network.PLAYER_HOST_ID, "_deploy_card", Global.player_data, unit)
	_ui.add_to_deck(._player_draw_card(Global.player_data.units, 1))
	._player_deploy_card(unit, Global.player_data.units)
	
func _unit_spawned():
	._unit_spawned()
	check_deck()
	
func _on_unit_dead(_unit):
	._on_unit_dead(_unit)
	check_deck()
	
	
	
func check_deck():
	var team = Global.player_data.team
	var coin = game_data[team].coin
	var pop = _number_of_unit_spawn($unit_holder,team)
	_ui.display_clickable_deck(pop, MAX_UNIT_SPAWN, coin)
	_ui.display_population(team, pop, MAX_UNIT_SPAWN)
	
################################################################
# if host player want to rematch
func _set_on_restart_match():
	Global.connect("on_host_game_session_ready", self, "_on_host_game_session_ready")
	
func _on_host_game_session_ready(_mp_game_data : Dictionary):
	Global.mp_game_data = _mp_game_data
	get_tree().change_scene("res://map/multi-player/client/battle.tscn")





