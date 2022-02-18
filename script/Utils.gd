extends Node
class_name Utils

static func create_hit_by(player : Dictionary, node_path : NodePath, team : String, color : Color) ->Dictionary:
	return {"player" : player, "node_path" : node_path, "team" : team, "color" : color}
