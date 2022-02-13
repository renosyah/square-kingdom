extends Node

const PERSISTEN_SAVE = false

const TEAM_1 = "TEAM_1"
const TEAM_2 = "TEAM_2"
const TEAMS = [TEAM_1, TEAM_2]

const AI_LEVEL = {
	"EASY" : {timeout = 15, deploy_chance = 0.2},
	"MEDIUM" : {timeout = 10, deploy_chance = 0.3},
	"HARD" : {timeout = 8, deploy_chance = 0.4}
}

func _ready():
	load_player_data()
	load_player_game_data()
	
################################################################
# player data
var player_data = {}

func new_player_data() -> Dictionary:
	return {
		id = "PLAYER-" + GDUUID.v4(),
		name = OS.get_name(),
		color = Color.blue,
		team = TEAM_1
	}
	
func save_player_data():
	if PERSISTEN_SAVE:
		SaveLoad.save("player.dat", player_data)
	
func load_player_data():
	var _player_data = null 
	
	if PERSISTEN_SAVE:
		_player_data = SaveLoad.load_save("player.dat")
		
	if not _player_data:
		_player_data = new_player_data()
		
	player_data = _player_data
	save_player_data()
	
################################################################
# game data
var player_game_data = {}

func save_player_game_data():
	if PERSISTEN_SAVE:
		SaveLoad.save("player_game_data.dat", player_game_data)
	
func load_player_game_data():
	var _player_game_data = null 
	
	if PERSISTEN_SAVE:
		_player_game_data = SaveLoad.load_save("player_game_data.dat")
		
	if not _player_game_data:
		_player_game_data = generate_game_data()
		
	player_game_data = _player_game_data
	save_player_game_data()
	
static func generate_game_data(max_farm : int = 10, max_tower : int = 4) -> Dictionary:
	var data = {
		TEAM_1 : {
			team_name = "",
			enable_ai = false,
			color = Color.blue,
			coin = 100,
			units = [],
		},
		TEAM_2 : {
			team_name = "",
			enable_ai = true,
			color = Color.red,
			coin = 100,
			units = [],
		},
		ai_level = {
			timeout = 15,
			deploy_chance = 0.2
		},
		buildings = []
	}
	
	for i in TEAMS:
		if data.has(i):
			data[i].team_name = RandomNameGenerator.generate()
			for u in Units.UNITS:
				var unit = u.duplicate()
				unit.team = i
				unit.color = data[i].color
				data[i].units.append(unit)
			
			var castle = Buildings.BUILDINGS[0].duplicate()
			castle.team = i
			castle.color = data[i].color
			data.buildings.append(castle)
			
	for i in max_farm:
		data.buildings.append(Buildings.BUILDINGS[1].duplicate())
		
	for i in max_tower:
		data.buildings.append(Buildings.BUILDINGS[2].duplicate())
		
	return data
	
################################################################
# multiplayer connection and data
const MODE_HOST = 0
const MODE_JOIN = 1
var mode = MODE_HOST

var server = {
	ip = '127.0.0.1',
	port = 31400,
	max_player = 4,
}
var client = {
	ip = '',
	port = 31400,
	network_unique_id = 0,
}

var mp_game_data = {}
var mp_exception_message = ""
################################################################
