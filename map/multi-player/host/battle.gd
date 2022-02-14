extends BattleMP

onready var _ui = $ui
onready var _camera = $cameraPivot

onready var _bot_timer = $bot_timer
onready var _countdown_start = $countdown_start
onready var _countdown_end = $countdown_end

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
	
func generate_spawn():
	randomize()
	
	var pos_1 = $spawn_point_1.get_children()
	var pos_2 = $spawn_point_2.get_children()
	
	var castle_spawn_pos = {
		Global.TEAM_1 : pos_1[randi() % pos_1.size()].translation,
		Global.TEAM_2 : pos_2[randi() % pos_2.size()].translation
	}
	game_data = Global.mp_game_data
	
	var pos = $terrain.translations.duplicate()
	
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
			
	_spawn_buildings($castle_holder.get_path(), $farm_holder.get_path())
	
	Global.rpc("on_host_game_session_ready", game_data)
	
################################################################
# camera
func _on_castle_spawn(_team, _translation):
	if _team != Global.player_data.team:
		return
		
	_camera.translation = _translation
	
################################################################
# grpc server func
remotesync func _game_info(_flag : int, _data : Dictionary):
	if _data.has("message"):
		_ui.display_loading(_flag == GAME_LOADING, _data.message)
	
	if _flag == GAME_START:
		_ui.add_to_deck(_draw_card(MAX_DRAW_CARD, Global.player_data.team))
		
	elif _flag == GAME_INFO:
		pass
		
	elif _flag == GAME_OVER:
		_countdown_end.start()
		_bot_timer.stop()
		
	elif _flag == GAME_FINISH:
		var is_win = winner_team == Global.player_data.team
		var condition = "Victory!" if is_win else "Defeat!"
		var message = "Our team win!" if is_win else "Our team lose!"
		_ui.display_game_over(true, condition, message)
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
	var message = _building_captured_message(_building.building_name,Global.player_data.team,_capture_by,_last_owner_team)
	if message == "":
		return

	_ui.display_info(message)
	
func _on_ui_on_deploy_card(unit):
	_deploy_card(unit)
	_ui.add_to_deck(_draw_card(1, unit.team))
	
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
# bot timer
func _on_bot_timer_timeout():
	randomize()
	
	for team in Global.TEAMS:
		if not game_data[team].enable_ai:
			continue
			
		var pop = _number_of_unit_spawn($unit_holder, team)
		if pop >= MAX_UNIT_SPAWN:
			continue
			
		var cards = _draw_card(3, team)
		var unit = cards[randi() % cards.size()]
		
		if randf() < game_data.ai_level.deploy_chance:
			continue
			
#		if game_data[team].coin - unit.cost < 0:
#			continue
#		game_data[team].coin -= unit.cost
#		rpc("_on_coin_updated",team, game_data[team].coin)
		
		unit.node_name = "UNIT-" + GDUUID.v4()
		unit.translation = castles[team].translation
		rpc("_spawn_unit", $unit_holder.get_path() , unit)
	
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




















