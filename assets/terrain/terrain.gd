extends StaticBody

onready var _grass = $grass
onready var _ground = $ground
onready var _collision_shape = $CollisionShape

var size = 80
var translations = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_grass.mesh.size = Vector3(size, 2, size)
	_ground.mesh.size = Vector3(size, 8, size)
	_collision_shape.shape = _grass.mesh.create_convex_shape(true, true)
	translations = _create_box_shape_translations()
	
func _create_box_shape_translations() -> Array:
	var pos = []
	var waypoint_position = translation
	var number_of_unit : int = 25
	var space_between_units : int = 8
	var square_side_size = round(sqrt(number_of_unit))
	var unit_pos = Vector3(waypoint_position.x, 0 ,waypoint_position.z) - space_between_units * Vector3(square_side_size/2,0,square_side_size/2)
	for i in number_of_unit:
		pos.append(unit_pos  + Vector3(0,0, 12))
		unit_pos.x += space_between_units
		if unit_pos.x > (waypoint_position.x + square_side_size * space_between_units / 2):
			unit_pos.z += space_between_units
			unit_pos.x = waypoint_position.x - space_between_units * square_side_size / 2
	return pos
