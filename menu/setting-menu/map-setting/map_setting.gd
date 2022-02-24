extends Control

onready var _spring = $VBoxContainer/map_setting/spring
onready var _winter = $VBoxContainer/map_setting/winter
onready var _antum = $VBoxContainer/map_setting/antum

onready var _map_small = $VBoxContainer/map_setting2/map_small_btn
onready var _map_normal = $VBoxContainer/map_setting2/map_normal_btn
onready var _map_large = $VBoxContainer/map_setting2/map_large_btn

# Called when the node enters the scene tree for the first time.
func _ready():
	set_all_disabled()
	apply_btn_condition()
	
func set_all_disabled():
	_spring.disabled = false
	_winter.disabled = false
	_antum.disabled = false
	
	_map_small.disabled = false
	_map_normal.disabled = false
	_map_large.disabled = false
	
	
func apply_btn_condition():
	_spring.disabled =  (Global.player_game_data.map_season == Global.GREEN_GRASS)
	_winter.disabled = (Global.player_game_data.map_season== Global.WHITE_SNOW)
	_antum.disabled = (Global.player_game_data.map_season == Global.YELLOW_SAND)
	
	_map_small.disabled =  (Global.player_game_data.map_size.name == Global.SMALL_SIZE.name)
	_map_normal.disabled = (Global.player_game_data.map_size.name == Global.NORMAL_SIZE.name)
	_map_large.disabled = (Global.player_game_data.map_size.name == Global.LARGE_SIZE.name)
	
	
func _on_antum_pressed():
	set_all_disabled()
	Global.player_game_data.map_season = Global.YELLOW_SAND
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_spring_pressed():
	set_all_disabled()
	Global.player_game_data.map_season = Global.GREEN_GRASS
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_winter_pressed():
	set_all_disabled()
	Global.player_game_data.map_season = Global.WHITE_SNOW
	apply_btn_condition()
	Global.save_player_game_data()
	
	
	
func _on_map_small_btn_pressed():
	set_all_disabled()
	Global.player_game_data.map_size = Global.SMALL_SIZE
	Global.player_game_data = Global.generate_farm_and_tower(Global.player_game_data, 6, 4, 2)
	apply_btn_condition()
	Global.save_player_game_data()
	
func _on_map_normal_btn_pressed():
	set_all_disabled()
	Global.player_game_data.map_size = Global.NORMAL_SIZE
	Global.player_game_data = Global.generate_farm_and_tower(Global.player_game_data, 8, 6, 4)
	apply_btn_condition()
	Global.save_player_game_data()

func _on_map_large_btn_pressed():
	set_all_disabled()
	Global.player_game_data.map_size = Global.LARGE_SIZE
	Global.player_game_data = Global.generate_farm_and_tower(Global.player_game_data, 12, 8, 6)
	apply_btn_condition()
	Global.save_player_game_data()
	
	
	



