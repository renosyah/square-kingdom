extends Node
class_name Utils

static func create_hit_by(player : Dictionary, node_path : NodePath, team : String, color : Color) ->Dictionary:
	return {"player" : player, "node_path" : node_path, "team" : team, "color" : color}


#const FLOAT_EPSILON = 0.00001
const FLOAT_EPSILON = 0.1

static func compare_floats(a, b, epsilon = FLOAT_EPSILON) -> bool:
	return abs(a - b) <= epsilon
