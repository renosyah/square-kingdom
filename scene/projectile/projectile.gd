extends Area

var sprite = "res://scene/projectile/arrow/arrow.png"

# attack
var attack_damage = 4.0

# speed
var speed = 25.0
var spread = 0.1
var travel_distance = 0.0
var max_distance = 45

# tag
var team : String = ""
var color : Color = Color.white

var velocity = Vector3.ZERO
var is_master : bool = true

func _ready():
	$Sprite3D.texture = load(sprite)
	$Sprite3D2.texture = load(sprite)
	set_as_toplevel(true)

func launch(to : Vector3):
	velocity = translation.direction_to(to)
	velocity.z += rand_range(-spread, spread)
	velocity.x += rand_range(-spread, spread)
	look_at(to, Vector3.UP)
	
func _process(delta):
	var _distance = speed * delta
	translation += velocity * _distance
	
	travel_distance += _distance
	if travel_distance > max_distance:
		set_process(false)
		queue_free()
	
func _on_projectile_body_entered(body):
	if not is_instance_valid(body):
		return
		
	if body.is_a_parent_of(self):
		return
		
	if body is StaticBody:
		return
		
	if body.team == team:
		return
		
	if is_master:
		body.take_damage(attack_damage, {node_path = get_parent().get_path(), team = team, color = color})
	
	set_process(false)
	queue_free()