extends BattleMP

onready var _ui = $ui
onready var _camera = $cameraPivot
onready var _terrain = $terrain

onready var _castle_holder = $castle_holder
onready var _farm_holder = $farm_holder
onready var _unit_holder = $unit_holder

onready var _tween_cinematic = $tween_cinematic

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	_init_client()
	
	randomize()
	var cin = CINEMATICS[randi() % CINEMATICS.size()]
	_camera.translation = cin.start
	_tween_cinematic.interpolate_property(_camera, "translation", _camera.translation, cin.end, 6.1)
	_tween_cinematic.start()
	
################################################################
# init client player
func _init_client():
	.init_connection_watcher()
	_set_on_restart_match()
	
	game_data = Global.mp_game_data.duplicate(true)
	MAX_UNIT_SPAWN = game_data.max_unit_spawn
	check_deck()
	
	_terrain.map_size = game_data.map_size
	_terrain.generate()
	
	_spawn_buildings(_castle_holder.get_path(), _farm_holder.get_path())
	_ui.update_victory_bar(_get_building_own_each_team(_castle_holder.get_path(), _farm_holder.get_path()))
	
################################################################
# grpc client func
remotesync func _game_info(_flag : int, _data : Dictionary):
	if _data.has("message"):
		_ui.display_loading(_flag == GAME_LOADING, _data.message)
	
	if _flag == GAME_START:
		_ui.add_to_deck(._player_draw_card(Global.player_data.units, MAX_DRAW_CARD))
		
		_tween_cinematic.stop(_camera, "translation")
		_tween_cinematic.interpolate_property(_camera, "translation", _camera.translation, castles[Global.player_data.team].translation, 2.1)
		_tween_cinematic.start()
		
	elif _flag == GAME_INFO:
		pass
		
	elif _flag == GAME_OVER:
		scores = _data.scores
		_ui.display_loading(true, "Battle is Over!")
		
	elif _flag == GAME_FINISH:
		winner_team = _data.winner
		var is_win = winner_team == Global.player_data.team
		var condition = "Victory!" if is_win else "Defeat!"
		var message = "Our team win!" if is_win else "Our team lose!"
		_ui.display_game_over(false, condition, message, scores)
		clear_entity()
	
func clear_entity():
	for i in _castle_holder.get_children() + _farm_holder.get_children() + _unit_holder.get_children():
		i.queue_free()
		
	_terrain.visible = false
	
################################################################
# update from ui and call update to ui
func on_coin_updated(_team : String , _amount : int):
	.on_coin_updated(_team, _amount)
	var team = Global.player_data.team
	
	if team != _team:
		return
		
	var pop = _number_of_unit_spawn(_unit_holder,team)
	_ui.display_clickable_deck(pop, MAX_UNIT_SPAWN, _amount)
	_ui.display_coin(_amount)
	
	
	
func _on_capture_progress(_building, _capture_by, _cp_damage, _cp, _max_cp):
	._on_capture_progress(_building, _capture_by, _cp_damage, _cp, _max_cp)
	if _building.type_building != Buildings.TYPE_CASTLE:
		return
		
	_ui.display_hurt(_building.team)
	
	
	
func on_building_captured(_building,_last_owner_team,_capture_by):
	.on_building_captured(_building,_last_owner_team,_capture_by)
	_ui.update_victory_bar(_get_building_own_each_team(_castle_holder.get_path(), _farm_holder.get_path()))
	
	var title = _building_captured_title(_building.building_name,Global.player_data.team,_capture_by,_last_owner_team)
	var message = _building_captured_message(_building,Global.player_data.team,_capture_by,_last_owner_team)
	if message == "" or title == "":
		return
		
	_ui.display_info(title, message)
	
	
func _on_ui_on_deploy_card(unit):
	var _player_clone = Global.player_data.duplicate()
	_player_clone.units = []
	rpc_id(Network.PLAYER_HOST_ID, "_deploy_card", _player_clone, unit)
	_ui.add_to_deck(._player_draw_card(Global.player_data.units, 1))
	._player_deploy_card(unit, Global.player_data.units)
	
func _unit_spawned(_unit):
	._unit_spawned(_unit)
	check_deck()
	
func _on_unit_dead(_unit):
	._on_unit_dead(_unit)
	check_deck()
	
	
	
func check_deck():
	var team = Global.player_data.team
	var coin = game_data[team].coin
	var pop = _number_of_unit_spawn(_unit_holder,team)
	_ui.display_clickable_deck(pop, MAX_UNIT_SPAWN, coin)
	_ui.display_population(team, pop, MAX_UNIT_SPAWN)
	
################################################################
# if host player want to rematch
func _set_on_restart_match():
	Global.connect("on_host_game_session_ready", self, "_on_host_game_session_ready")
	
func _on_host_game_session_ready(_mp_game_data : Dictionary):
	Global.mp_game_data = _mp_game_data
	get_tree().change_scene("res://map/multi-player/client/battle.tscn")





