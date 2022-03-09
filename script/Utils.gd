extends Node
class_name Utils

static func create_hit_by(player : Dictionary, node_path : NodePath, team : String, color : Color) ->Dictionary:
	return {"player" : player, "node_path" : node_path, "team" : team, "color" : color}


const FLOAT_EPSILON = 0.00001

static func compare_floats(a, b, epsilon = FLOAT_EPSILON) -> bool:
	return abs(a - b) <= epsilon
	
	
enum {
	FORMAT_HOURS   = 1 << 0,
	FORMAT_MINUTES = 1 << 1,
	FORMAT_SECONDS = 1 << 2,
	FORMAT_DEFAULT = FORMAT_HOURS | FORMAT_MINUTES | FORMAT_SECONDS
}
	
static func format_time(time, format = FORMAT_DEFAULT, digit_format = "%02d", colon = " : "):
	var digits = []
	
	if format & FORMAT_HOURS:
		var hours = digit_format % [time / 3600]
		digits.append(hours)
	
	if format & FORMAT_MINUTES:
		var minutes = digit_format % [time / 60]
		digits.append(minutes)
	
	if format & FORMAT_SECONDS:
		var seconds = digit_format % [int(ceil(time)) % 60]
		digits.append(seconds)
	
	var formatted = String()
	
	for digit in digits:
		formatted += digit + colon

	if not formatted.empty():
		formatted = formatted.rstrip(colon)

	return formatted
