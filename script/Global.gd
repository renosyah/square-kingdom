extends Node

const VERSION_SAVE = "1.4"
var PERSISTEN_SAVE = true

const DEKSTOP =  ["Server", "Windows", "WinRT", "X11"]
const REDEEM_CODES = ["AGUSGEH","WRUGEH","UGEH"]

const TEAM_1 = "TEAM_1"
const TEAM_2 = "TEAM_2"
const TEAMS = [TEAM_1, TEAM_2]

const EASY_AI = "EASY"
const MEDIUM_AI = "MEDIUM"
const HARD_AI = "HARD"

const AI_LEVEL = {
	 EASY_AI : {
		"name": EASY_AI,
		"timeout" : 5,
		"deploy_chance" : 0.65
	},
	 MEDIUM_AI : {
		"name": MEDIUM_AI,
		"timeout" : 4,
		"deploy_chance" : 0.70
	},
	 HARD_AI : {
		"name": HARD_AI,
		"timeout" : 3,
		"deploy_chance" : 0.80
	}
}

const SMALL_SIZE = { 
	"name" : "Small",
	"size" : 1,
	"number_of_unit" : 24,
	"space" : 9, 
	"offset" : 2 
} #OK

const NORMAL_SIZE = { 
	"name" : "Normal",
	"size" : 1.5,
	"number_of_unit" : 36,
	"space" : 9, 
	"offset" : 14
} #OK

const LARGE_SIZE = { 
	"name" : "Large",
	"size" : 2,
	"number_of_unit" : 54,
	"space" : 9,
	"offset" : 18
} #OK

const GREEN_GRASS = Color(0, 0.686275, 0.117647)
const WHITE_SNOW = Color(0.750643, 0.792025, 0.797363)
const YELLOW_SAND = Color(0.737255, 0.482353, 0.039216)

const SEASONS = [GREEN_GRASS, WHITE_SNOW, YELLOW_SAND]


func _ready():
	PERSISTEN_SAVE = not OS.get_name() in DEKSTOP
	load_player_data()
	load_player_game_data()
	load_player_inventories()
	load_audio_setting()
	play_music()
	
################################################################
# autoplay feature
# auto deploy unit
var enable_autoplay = false 
	
################################################################
# play music!
const AUDIO_SAVE_FILE = "audio_setting" + "_" + VERSION_SAVE + ".dat"
var _audio
var audio_setting = { music = false, sfx = true }

func play_music():
	if not _audio:
		_audio = AudioStreamPlayer.new()
		#_audio.volume_db = -20
		_audio.stream = preload("res://assets/sound/music.ogg")
		_audio.bus = "music"
		add_child(_audio)
		
	if audio_setting.music:
		_audio.play()
	else:
		_audio.stop()
		
func save_audio_setting():
	if PERSISTEN_SAVE:
		SaveLoad.save(AUDIO_SAVE_FILE, audio_setting)
	
func load_audio_setting():
	var _audio_setting = null 
	
	if PERSISTEN_SAVE:
		_audio_setting = SaveLoad.load_save(AUDIO_SAVE_FILE)
		
	if not _audio_setting:
		_audio_setting = { music = false, sfx = true }
		
	audio_setting  = _audio_setting 
	save_audio_setting()
	
################################################################
# player data
const PLAYER_DATA_SAVE_FILE = "player" + "_" + VERSION_SAVE + ".dat"
var player_data = {}

func new_player_data() -> Dictionary:
	var _data = {
		id = "PLAYER-" + GDUUID.v4(),
		name = "",
		color = Color.blue,
		team = TEAM_1,
		units = [],
	}
	
	for i in 8:
		var unit = Units.UNITS[i].duplicate()
		unit.id = "UNIT-" + str(GDUUID.v4()) + "-starter"
		unit.team = TEAM_1
		unit.color = Color.blue
		_data.units.append(unit)
		
	return _data
	
func check_player_name() -> bool:
	if (player_data.name).to_upper() in REDEEM_CODES:
		unlock_all_unit()
		return true
		
	return false
	
func apply_players_unit_team():
	for i in player_data.units:
		i.team = player_data.team
		i.color = player_data.color
		i.is_draw = false
	
func save_player_data():
	if PERSISTEN_SAVE:
		SaveLoad.save(PLAYER_DATA_SAVE_FILE, player_data)
	
func load_player_data():
	var _player_data = null 
	
	if PERSISTEN_SAVE:
		_player_data = SaveLoad.load_save(PLAYER_DATA_SAVE_FILE)
		
	if not _player_data:
		_player_data = new_player_data()
		
	player_data = _player_data
	save_player_data()
	
################################################################
# player inventories
const FLAG_UNIT_LOCKED = 1
const FLAG_UNIT_UNLOCKED = 2

const PLAYER_INVENTORIES_SAVE_FILE = "player_inventories" + "_" + VERSION_SAVE + ".dat"
var player_inventories = []

func apply_players_unit_inventories():
	for i in player_inventories:
		i.team = player_data.team
		i.color = player_data.color
		i.is_draw = false
		
func save_player_inventories():
	if PERSISTEN_SAVE:
		SaveLoad.save(PLAYER_INVENTORIES_SAVE_FILE, player_inventories)
	
func load_player_inventories():
	var _player_inventories = null 
	
	if PERSISTEN_SAVE:
		_player_inventories = SaveLoad.load_save(PLAYER_INVENTORIES_SAVE_FILE)
		
	if not _player_inventories:
		_player_inventories = []
		for i in range(8, Units.UNITS.size()):
			var unit = Units.UNITS[i].duplicate()
			unit.id = "UNIT-" + str(GDUUID.v4()) + "-starter"
			unit.team = TEAM_1
			unit.color = Color.blue
			_player_inventories.append(unit)
			
		for i in 45:
			var unit = Units.generate_random_locked_unit()
			unit.team = TEAM_1
			unit.color = Color.blue
			unit["FLAG"] = FLAG_UNIT_LOCKED
			_player_inventories.append(unit)
		
	player_inventories = _player_inventories
	save_player_inventories()
	
	
func unlock_random_card_in_inventory(max_unlock : int = 1) -> Array:
	var unlocked = []
	
	randomize()
	var _player_inventories = []
	
	for unit in player_inventories:
		if unit.has("FLAG"):
			if unit["FLAG"] == FLAG_UNIT_LOCKED:
				_player_inventories.append(unit)
		
	if _player_inventories.empty():
		return unlocked
		
	_player_inventories.shuffle()
	
	for i in max_unlock:
		var unit = _player_inventories[randi() % _player_inventories.size()]
		unit["FLAG"] = FLAG_UNIT_UNLOCKED
		unlocked.append(unit)
		
	save_player_inventories()
	return unlocked
	
	
func unlock_all_unit():
	for unit in player_inventories:
		unit["FLAG"] = FLAG_UNIT_UNLOCKED
		
################################################################
# game data
const PLAYER_GAME_DATA_SAVE_FILE = "player_game_data" + "_" + VERSION_SAVE + ".dat"
var player_game_data = {}

func save_player_game_data():
	if PERSISTEN_SAVE:
		SaveLoad.save(PLAYER_GAME_DATA_SAVE_FILE, player_game_data)
	
func load_player_game_data():
	var _player_game_data = null 
	
	if PERSISTEN_SAVE:
		_player_game_data = SaveLoad.load_save(PLAYER_GAME_DATA_SAVE_FILE)
		
	if not _player_game_data:
		_player_game_data = generate_game_data()
		
	player_game_data = _player_game_data
	save_player_game_data()
	
static func generate_game_data() -> Dictionary:
	var data = {
		TEAM_1 : {
			team_name = "",
			enable_ai = true,
			color = Color.blue,
			coin = 25,
		},
		TEAM_2 : {
			team_name = "",
			enable_ai = true,
			color = Color.red,
			coin = 25,
		},
		ai_level = AI_LEVEL[EASY_AI],
		buildings = [],
		map_size = SMALL_SIZE,
		map_season = GREEN_GRASS,
		max_unit_spawn = 10,
		time_limit = 300
	}
	
	for i in TEAMS:
		if data.has(i):
			data[i].team_name = RandomNameGenerator.generate()
			
			var castle = Buildings.BUILDINGS[0].duplicate()
			castle.team = i
			castle.garrison_units = create_array_range(6)
			castle.color = data[i].color
			data.buildings.append(castle)
			
	data = generate_farm_and_tower(data)
		
	return data
	
static func generate_farm_and_tower(data : Dictionary, max_farm = 6, max_tower = 4, max_unit_buffer : int = 2, max_tower_platform : int = 1) -> Dictionary:
	randomize()
	
	var holder = []
	for i in data.buildings:
		if i.type_building == Buildings.TYPE_CASTLE:
			holder.append(i)
			
	data.buildings.clear()
	data.buildings.append_array(holder)
	
	for i in max_farm:
		var farm = Buildings.BUILDINGS[1].duplicate()
		farm.id = "FARM-" + GDUUID.v4()
		farm.amount = round(rand_range(2,10))
		farm.coin_produce_cooldown = rand_range(10,15)
		data.buildings.append(farm)
		
	for i in max_tower:
		var tower = Buildings.BUILDINGS[2].duplicate()
		tower.id = "TOWER-" + GDUUID.v4()
		tower.garrison_units = create_array_range(4)
		tower.attack_damage = rand_range(2,8)
		data.buildings.append(tower)
		
	for i in max_unit_buffer:
		var training_field = Buildings.BUILDINGS[3].duplicate()
		training_field.id = "TRAINING-FIELD-" + GDUUID.v4()
#		var buff = create_training_field_buff()
#		training_field.upgrades = buff["upgrades"]
#		training_field.pivot = buff["pivot"]
		data.buildings.append(training_field)
		
	for i in max_tower_platform:
		var tower = Buildings.BUILDINGS[4].duplicate()
		tower.id = "TOWER-PLATFORM-" + GDUUID.v4()
		#tower.turret_data = create_tower_platform_turret_data()
		data.buildings.append(tower)
		
	return data
	
static func create_tower_platform_turret_data() -> Dictionary:
	var turret_scenes = {
		"res://scene/units/sieges/balista/balista_bow/balista_bow.tscn" : {
			"attack_damage" : 16.0,
			"delay" : 2.5,
			"range_attack" : 20.0,
			"platform_name" : "Balista Tower"
		},
		"res://scene/units/sieges/howitzer/howitzer_turret/howitzer_turret.tscn" : {
			"attack_damage" : 24.0,
			"delay" : 8.5,
			"range_attack" : 25.0,
			"platform_name" : "Howitzer Tower"
		},
		"res://scene/units/sieges/onager/onager_turret/onager_turret.tscn" : {
			"attack_damage" : 14.0,
			"delay" : 6.5,
			"range_attack" : 20.0,
			"platform_name" : "Onager Tower"
		},
		"res://scene/units/sieges/repeater/repeater_turret/repeater_turret.tscn" : {
			"attack_damage" : 3.0,
			"delay" : 0.2,
			"range_attack" : 20.0,
			"platform_name" : "Repeater Tower"
		},
#		"res://scene/units/sieges/siege_tower/siege_tower_turret/siege_tower_turret.tscn" : {
#			"attack_damage" : 3.5,
#			"delay" : 1.0,
#			"range_attack" : 15.0,
#			"garrison_units" : create_array_range(6),
#			"platform_name" : "Archer Tower"
#		}
	}
	
	randomize()
	var key = turret_scenes.keys()[randi() % turret_scenes.keys().size()]
	var data = turret_scenes[key]
	data["turret_scene"] = key
	data["platform_name"] = data["platform_name"]
	
	return data
	
static func create_training_field_buff() -> Dictionary:
	var pivots = ["PV_1","PV_2","PV_3"]
	var type_upgrades = [
		["attack_damage","Unit Attack Damage"],
		["max_hp","Unit Hitpoint"],
		["speed","Unit Walking Speed"],
		["capture_damage","Unit Capturing building"]
	]
	var key = type_upgrades[randi() % type_upgrades.size()]
	return {
		"upgrades" : { 
			key[0] : { "name" : key[1], "value" : stepify(rand_range(0.10, 0.50), 0.01) }
		},
		"pivot" : pivots[randi() % pivots.size()]
	}
	
static func create_array_range(_range : int) -> Array:
	var arr = []
	var mult = 0.2
	for i in _range:
		arr.append(rand_range(1,2) + mult)
		mult += 0.2
		
	return arr
	
static func generate_ai_units(_ai_name : String) -> Array:
	var ai_unit = []
	var count = int(rand_range(8, 12))
	for i in count:
		var unit = Units.UNITS[i].duplicate()
		ai_unit.append(unit)
		
	if _ai_name == MEDIUM_AI:
		for i in 2:
			var unit = Units.generate_random_locked_unit()
			ai_unit.append(unit)
		
	elif _ai_name == HARD_AI:
		for i in 4:
			var unit = Units.generate_random_locked_unit()
			ai_unit.append(unit)
		
	return ai_unit
	
################################################################
# multiplayer connection and data
signal on_host_game_session_ready(_mp_game_data)

remotesync func on_host_game_session_ready(_mp_game_data : Dictionary):
	emit_signal("on_host_game_session_ready", _mp_game_data)

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
