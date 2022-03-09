extends BattleMP

onready var _ui = $ui
onready var _camera = $cameraPivot
onready var _camera_cam = $cameraPivot/Camera
onready var _terrain = $terrain

onready var _bot_timer = $bot_timer
onready var _countdown_start = $countdown_start
onready var _countdown_end = $countdown_end

onready var _castle_holder = $castle_holder
onready var _farm_holder = $farm_holder
onready var _unit_holder = $unit_holder

onready var _tween_cinematic = $tween_cinematic
onready var _tween_cinematic_end = $tween_cinematic_end

var _time_count_down = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	_init_host()
	
################################################################
# init host player
func _init_host():
	.init_connection_watcher()
	generate_spawn()
	
	randomize()
	var cin = CINEMATICS[randi() % CINEMATICS.size()]
	_camera.translation = cin.start
	_tween_cinematic.interpolate_property(_camera, "translation", _camera.translation, cin.end, 6.1)
	_tween_cinematic.start()
	
func generate_spawn():
	randomize()
	
	game_data = Global.mp_game_data.duplicate(true)
	MAX_UNIT_SPAWN = game_data.max_unit_spawn
	check_deck()
	
	ai_units = Global.generate_ai_units(game_data.ai_level["name"])
	
	_terrain.season = game_data.map_season
	_terrain.map_size = game_data.map_size
	_terrain.generate()
	
	#_camera.camera_keep_aspect(Camera.KEEP_WIDTH if (not OS.get_name() in Global.DEKSTOP) else Camera.KEEP_HEIGHT)
	
	var pos_1 = _terrain.west_spawn_translations
	var pos_2 = _terrain.east_spawn_translations
	
	var castle_spawn_pos = {
		Global.TEAM_1 : pos_1[randi() % pos_1.size()],
		Global.TEAM_2 : pos_2[randi() % pos_2.size()]
	}
	
	if randf() < 0.5:
		castle_spawn_pos = {
			Global.TEAM_1 : pos_2[randi() % pos_2.size()],
			Global.TEAM_2 : pos_1[randi() % pos_1.size()]
		}

	var pos = _terrain.translations.duplicate()
	
	for i in game_data.buildings:
		if i.type_building == Buildings.TYPE_CASTLE:
			i.node_name = "CASTLE-" + GDUUID.v4()
			i.translation = castle_spawn_pos[i.team]
			
		elif i.type_building == Buildings.TYPE_FARM:
			var p = pos[randi() % pos.size()]
			i.node_name = "FARM-" + GDUUID.v4()
			i.translation = p
			pos.erase(p)
			
		elif i.type_building == Buildings.TYPE_TOWER:
			var p = pos[randi() % pos.size()]
			i.node_name = "TOWER-" + GDUUID.v4()
			i.translation = p
			pos.erase(p)
			
		elif i.type_building == Buildings.TYPE_UNIT_BUFF:
			var buff = Global.create_training_field_buff()
			var p = pos[randi() % pos.size()]
			i.node_name = "TRAINING-FIELD-" + GDUUID.v4()
			i.translation = p
			i.upgrades = buff["upgrades"]
			i.pivot = buff["pivot"]
			pos.erase(p)
			
		elif i.type_building == Buildings.TYPE_TOWER_PLATFORM:
			var p = pos[randi() % pos.size()]
			i.node_name = "TOWER-PLATFORM-" + GDUUID.v4()
			i.turret_data = Global.create_tower_platform_turret_data()
			i.translation = p
			pos.erase(p)
			
			
	_spawn_buildings(_castle_holder.get_path(), _farm_holder.get_path())
	_ui.update_victory_bar(_get_building_own_each_team(_castle_holder.get_path(), _farm_holder.get_path()))
	
	Global.rpc("on_host_game_session_ready", game_data)
	
################################################################
# grpc server func
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
		_ui.clear_deck()
		_ui.display_loading(true, "Battle is Over!")
		_countdown_end.wait_time = 3
		_countdown_end.start()
		_bot_timer.stop()
		
	elif _flag == GAME_FINISH:
		var is_win = winner_team == Global.player_data.team
		var condition = "Victory!" if is_win else "Defeat!"
		var message = "Our team win!" if is_win else "Our team lose!"
		message = "Both team lose!" if winner_team == "" else message
		condition = "Draw!" if winner_team == "" else condition
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
	._deploy_card(_player_clone, unit)
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
	
func update_battle_time(_time_left_in_second : int):
	.update_battle_time(_time_left_in_second)
	_ui.display_time_limit(_time_left_in_second)
	
func on_player_disynchronize(_player_name : String):
	.on_player_disynchronize(_player_name)
	_ui.display_player_disynchronize(_player_name)
	
################################################################
# bot timer
func _on_bot_timer_timeout():
	randomize()
	
	for team in Global.TEAMS:
		if not game_data[team].enable_ai:
			continue
			
		if randf() > game_data.ai_level.deploy_chance:
			continue
			
		var pop = _number_of_unit_spawn(_unit_holder, team)
		if pop >= MAX_UNIT_SPAWN:
			continue
			
		var cards = .ai_draw_card(MAX_DRAW_CARD, game_data[team].coin)
		if cards.empty():
			continue
			
		var bot = { 
			"id" : "BOT-" + game_data.ai_level.name,
			"name" : "BOT-" + game_data.ai_level.name,
			"color" : game_data[team].color,
			"is_bot" : ""
		}
		
		var unit = cards[randi() % cards.size()]
		game_data[team].coin -= unit.cost
		
		unit.node_name = "UNIT-" + GDUUID.v4()
		unit.translation = castles[team].translation
		unit.team = team
		unit.color = game_data[team].color
		rpc("_spawn_unit", _unit_holder.get_path(), bot, unit)
	
func _on_countdown_start_timeout():
	var message = "Ready in " + str(_time_count_down) + "..."
	
	if _time_count_down == 0:
		message = "Go..."
	
	if _time_count_down < 0:
		game_flag = GAME_START
		_bot_timer.wait_time = game_data.ai_level.timeout
		_bot_timer.start()
		_countdown_start.stop()
		
	rpc("_game_info", game_flag , { message =  message })
	
	_time_count_down -= 1
	
func _on_countdown_end_timeout():
	game_flag = GAME_FINISH
	rpc("_game_info", game_flag , { winner = winner_team, message = "" })
	
func _on_coin_update_timeout():
	rpc_unreliable("_on_coin_updated", _get_coin_each_team())
	
func _on_battle_timer_timeout():
	if game_flag != GAME_START:
		return
		
	if game_data.time_limit == -1:
		return
		
	game_data.time_limit -= 1
	rpc_unreliable("_update_battle_time", game_data.time_limit)
		
	if game_flag == GAME_OVER:
		return
		
	if game_data.time_limit == 0:
		# draw winner is empty
		winner_team = ""
		game_flag = GAME_OVER
		rpc("_game_info",  game_flag , { message =  "", "scores" : scores })



























