extends Spatial

var _sprites : Array
var _raycast : RayCast

var sprite = ""

# attack
var attack_damage = 4.0

# speed
var speed = 25.0
var spread = 1.5

# tag
var player = {}
var team : String = ""
var color : Color = Color.white

var velocity = Vector3.ZERO
var is_master : bool = true
var _timeout_timer

# misc
var parent

func _ready():
	set_as_toplevel(true)
	_timeout_timer = Timer.new()
	_timeout_timer.wait_time = 5
	_timeout_timer.one_shot = true
	_timeout_timer.autostart = true
	_timeout_timer.connect("timeout", self, "_timeout_timer_timeout")
	add_child(_timeout_timer)
	parent = get_parent()
	
	init_projectile()
	
func init_projectile():
	_sprites = [$Sprite3D, $Sprite3D2]
	_raycast = $raycast
	
	if sprite != "":
		for i in _sprites:
			i.texture = load(sprite)
	
func launch(to : Vector3):
	to.z += rand_range(-spread, spread)
	to.x += rand_range(-spread, spread)
	to.y += rand_range(-spread, spread)
	velocity = translation.direction_to(to)
	look_at(to, Vector3.UP)
	
func _process(delta):
	var _distance = speed * delta
	translation += velocity * _distance
	
	if _raycast.is_colliding():
		_on_projectile_body_entered(_raycast.get_collider())
	
func _timeout_timer_timeout():
	queue_free()
	
func _on_projectile_body_entered(body):
	if not is_instance_valid(body):
		return
		
	if body.is_a_parent_of(self):
		return
		
	if body is GameplayCamera:
		return
		
	if body is StaticBody:
		stop_projectile()
		return
		
	if body.team == team:
		return
		
	if is_master:
		body.take_damage(
			attack_damage,
			Utils.create_hit_by(player, parent.get_path(), team, color)
		)
	
	stop_projectile()
	
	
func stop_projectile():
	set_process(false)





