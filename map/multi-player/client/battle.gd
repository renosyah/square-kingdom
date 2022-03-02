extends BattleMP

onready var _ui = $ui
onready var _camera = $cameraPivot
onready var _camera_cam = $cameraPivot/Camera
onready var _terrain = $terrain

onready var _castle_holder = $castle_holder
onready var _farm_holder = $farm_holder
onready var _unit_holder = $unit_holder

onready var _tween_cinematic = $tween_cinematic
onready var _tween_cinematic_end = $tween_cinematic_end

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
	_terrain.season = game_data.map_season
	_terrain.generate()
	
	#_camera.camera_keep_aspect(Camera.KEEP_WIDTH if (not OS.get_name() in Global.DEKSTOP) else Camera.KEEP_HEIGHT)
	
	_spawn_buildings(_castle_holder.get_path(), _farm_holder.get_path())
	_ui.update_victory_bar(_get_building_own_each_team(_castle_holder.get_path(), _farm_holder.get_path()))
	
################################################################
# grpc client func
remotesync func _game_info(_flag : int, _data : Dictionary):
	if _data.has("message"):
		_ui.display_loading(_flag == GAME_LOADING, _data.message)
	
	if _flag == GAME_START:
		_ui.add_to_deck(._player_draw_card(Global.player_data.units, MAX_DRAW_CARD))
		
		var castle_pos = castles[Global.player_data.team].translation
		castle_pos.y = CAMERA_HEIGHT
		_tween_cinematic.stop(_camera, "translation")
		_tween_cinematic.interpolate_property(_camera, "translation", _camera.translation,castle_pos, 2.1)
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
		_ui.display_game_over(is_win, condition, message, scores)
		
		_tween_cinematic_end.interpolate_property(_camera_cam, "rotation_degrees:x", -15.0 , 90, 1.3)
		_tween_cinematic_end.start()
		
################################################################
# camera finish cinematic move at end game
func _on_tween_cinematic_end_tween_all_completed():
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
		
	_ui.display_buff_in_deck(get_owned_buff_building())
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
	
func get_owned_buff_building() -> Array:
	var buff_owned = []
	for i in _farm_holder.get_children():
		if i.team != Global.player_data.team:
			continue
		if i.type_building != Buildings.TYPE_UNIT_BUFF:
			continue
			
		buff_owned += i.upgrades.keys()
		
	var clean_buff_owned = []
	for i in buff_owned:
		if not clean_buff_owned.has(i):
			clean_buff_owned.append(i)
			
	return clean_buff_owned
	
func on_player_disynchronize(_player_name : String):
	.on_player_disynchronize(_player_name)
	_ui.display_player_disynchronize(_player_name)
	
################################################################
# if host player want to rematch
func _set_on_restart_match():
	Global.connect("on_host_game_session_ready", self, "_on_host_game_session_ready")
	
func _on_host_game_session_ready(_mp_game_data : Dictionary):
	Global.mp_game_data = _mp_game_data
	get_tree().change_scene("res://map/multi-player/client/battle.tscn")








