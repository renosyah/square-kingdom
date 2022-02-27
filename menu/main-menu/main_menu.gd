extends Node

onready var _camera = $cameraPivot
onready var _terrain = $terrain
onready var _team_1_flag = $castle_1/flag
onready var _team_2_flag = $castle_2/flag

# Called when the node enters the scene tree for the first time.
func _ready():
	_terrain.season = Global.player_game_data.map_season
	_terrain.generate()
	
	_team_1_flag.set_flag_color(Global.player_game_data[Global.TEAM_1].color)
	_team_2_flag.set_flag_color(Global.player_game_data[Global.TEAM_2].color)
	
	#_camera.camera_keep_aspect(Camera.KEEP_WIDTH if (not OS.get_name() in Global.DEKSTOP) else Camera.KEEP_HEIGHT)
	
