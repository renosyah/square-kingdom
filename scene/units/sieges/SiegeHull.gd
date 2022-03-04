extends Unit
class_name SiegeHull

onready var turn_speed = speed
############################################################
# multiplayer func
func _set_puppet_translation(_val :Vector3):
	._set_puppet_translation(_val)
	
func _set_puppet_moving_state(_val : Dictionary):
	._set_puppet_moving_state(_val)
	
remotesync func _take_damage(_damage : float, _hit_by: Dictionary):
	._take_damage(_damage, _hit_by)
	
remotesync func _perform_attack():
	._perform_attack()
	
remotesync func _dead():
	._dead()
	
############################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	
func puppet_moving(delta):
	.puppet_moving(delta)
	if is_dead:
		return
	
	rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, delta * 5)
	
func master_moving(delta):
	# we override this shit!
	#.master_moving(delta)
	if is_dead:
		return
		
	moving_state.is_walking = false
		
	if not target:
		set_process(false)
		return
		
	if is_instance_valid(target):
		direction = translation.direction_to(target.translation)
		distance_to_target = translation.distance_to(target.translation)
		
		# transform_turning(Vector3(target.translation.x , translation.y ,target.translation.z), delta)
		if not target.is_targetable(team):
			target = null
			set_process(false)
			return
			
		elif distance_to_target > range_attack:
			moving_state.is_walking = true
			translation.y -= (1.0 * delta) if translation.y > 0.0 else 0.0
			velocity = Vector3(direction.x, 0.0 , direction.z) * speed
			transform_turning(Vector3(target.translation.x , translation.y ,target.translation.z), delta)
			
		elif distance_to_target <= range_attack:
			velocity = Vector3.ZERO
			if _cooldown_timmer.is_stopped():
				perform_attack()
				_cooldown_timmer.start()
				
		if not is_on_floor():
			velocity.y -= gravity * delta
			
		velocity = move_and_slide(velocity, Vector3.UP)
			
	else:
		set_process(false)
		return
		
		
func transform_turning(direction, delta):
	var new_transform = transform.looking_at(direction, Vector3.UP)
	transform = transform.interpolate_with(new_transform, turn_speed * delta)
	
	
func break_random_part(_pivot : Spatial):
	var _body = _pivot.get_children()
	var _max_break = _body.size()
	var _break = int(rand_range(4,_max_break))
	for i in _break:
		_body[randi() % _body.size()].visible = false
	
	
func spawn_explosive():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	explosive.scale = Vector3.ONE * 12
	add_child(explosive)
	explosive.translation = translation



