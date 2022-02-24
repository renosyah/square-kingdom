extends StaticBody

onready var _pivot = $pivot
onready var _grass = $pivot/grass
onready var _collision_shape = $CollisionShape
onready var _spawn_translations = [
	$pivot/Position_1,
	$pivot/Position_2,
	$pivot/Position_3,
	$pivot/Position_4,
	$pivot/Position_5,
	$pivot/Position_6,
	$pivot/Position_7,
	$pivot/Position_8
]
onready var clifs = [
	$pivot/cliff_top/cliff1,
	$pivot/cliff_top/cliff2,
	$pivot/cliff_top/cliff3
]

var map_size = Global.NORMAL_SIZE
var translations = []
var east_spawn_translations = []
var west_spawn_translations = []
var season = Global.GREEN_GRASS

func _ready():
	var material = _grass.mesh.surface_get_material(0)
	material.albedo_color = season
	_grass.set_surface_material(0, material)
	
	for i in clifs:
		i.set_surface_material(0, material)

func generate():
	var material = _grass.mesh.surface_get_material(0)
	material.albedo_color = season
	_grass.set_surface_material(0, material)
	
	for i in clifs:
		i.set_surface_material(0, material)
		
	_pivot.scale = Vector3(map_size.size, 1, map_size.size)
	_collision_shape.shape = _grass.mesh.create_convex_shape(true, true)
	_collision_shape.scale = _pivot.scale
	translations = _create_box_shape_translations()
	_update_each_spawn_translations()
#
#	for i in translations:
#		var ball = $ball.duplicate()
#		ball.visible = true
#		ball.translation = i
#		add_child(ball)
#
	for i in [$pivot/Position_1,$pivot/Position_2,$pivot/Position_3,$pivot/Position_7]:
		east_spawn_translations.append(i.translation)
		
	for i in [$pivot/Position_4,$pivot/Position_5,$pivot/Position_6,$pivot/Position_8]:
		west_spawn_translations.append(i.translation)
		
		
func _update_each_spawn_translations():
	var multiplier = map_size.offset
	_spawn_translations[0].translation += Vector3(multiplier * map_size.size,0, -multiplier * map_size.size)
	_spawn_translations[1].translation += Vector3(multiplier * map_size.size,0,0)
	_spawn_translations[2].translation += Vector3(multiplier * map_size.size,0, multiplier * map_size.size)
	
	_spawn_translations[3].translation -= Vector3(multiplier * map_size.size,0, multiplier * map_size.size)
	_spawn_translations[4].translation -= Vector3(multiplier * map_size.size,0,0)
	_spawn_translations[5].translation -= Vector3(multiplier * map_size.size,0, -multiplier * map_size.size)
	
	_spawn_translations[6].translation += Vector3(0,0,-multiplier * map_size.size)
	_spawn_translations[7].translation += Vector3(0,0,multiplier * map_size.size)
	
	
func _create_box_shape_translations() -> Array:
	var pos = []
	var waypoint_position = translation
	var number_of_unit : int = map_size.number_of_unit
	var space_between_units : int = map_size.space
	var square_side_size = round(sqrt(number_of_unit))
	var unit_pos = Vector3(waypoint_position.x, 0 ,waypoint_position.z) - space_between_units * Vector3(square_side_size/2,0,square_side_size/2)
	for i in number_of_unit:
		pos.append(unit_pos  + Vector3(0,0, 12))
		unit_pos.x += space_between_units
		if unit_pos.x > (waypoint_position.x + square_side_size * space_between_units / 2):
			unit_pos.z += space_between_units
			unit_pos.x = waypoint_position.x - space_between_units * square_side_size / 2
	return pos
