extends Unit

onready var _owner = $owner
onready var _hp_bar = $hpBar
onready var _pivot = $pivot
onready var _tween = $Tween
onready var _tween_dead = $Tween_dead
onready var _audio = $AudioStreamPlayer3D

onready var turn_speed = speed

var _ram_weapon
var _wheels

############################################################
# multiplayer func
func _set_puppet_translation(_val :Vector3):
	._set_puppet_translation(_val)
	if is_dead:
		translation = _puppet_translation
		return
		
	_tween.interpolate_property(self,"translation", translation, _puppet_translation, 0.5)
	_tween.start()
	

func _set_puppet_moving_state(_val : Dictionary):
	._set_puppet_moving_state(_val)
	if is_dead:
		return
		
	for i in _wheels:
		if moving_state.is_walking:
			i.rotate_wheel()
		else:
			i.stop_wheel()
	
remotesync func _take_damage(_damage : float, _hit_by: Dictionary):
	._take_damage(_damage, _hit_by)
	
	if is_dead:
		return
		
	_hp_bar.update_bar(hp,max_hp)
	_tween.interpolate_property(_hp_bar, "modulate:a", 1 , 0, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
		
remotesync func _perform_attack():
	._perform_attack()
	
	_ram_weapon.attack()
	
	_audio.stream = preload("res://assets/sound/cant_click.wav")
	_audio.play()
	
remotesync func _dead():
	._dead()
	
	spawn_explosive()
	break_random_part()
	
	_audio.stream = load("res://assets/sound/explode3.wav")
	_audio.play()
	
	_tween_dead.interpolate_property(_pivot, "translation:y", _pivot.translation.y , -4, 5.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween_dead.start()
	
############################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	if not player.empty():
		_owner.set_message(player.name)
		
	_hp_bar.show_label(false)
	_hp_bar.set_hp_bar_color(color)
	_hp_bar.update_bar(hp,max_hp)
	_hp_bar.modulate.a = 0.0
	
	set_process(true)
	init_siege()
	
func init_siege():
	_ram_weapon = $pivot/ram
	_wheels = [$pivot/wheel_1, $pivot/wheel_2, $pivot/wheel_3, $pivot/wheel_4,$pivot/wheel_5, $pivot/wheel_6]
	$pivot/flag.set_flag_color(color)
	
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
	
func perform_attack():
	.perform_attack()
	
	if not is_master():
		return
		
	if target is Building:
		target.capture(
			capture_damage, Utils.create_hit_by(player, self.get_path(), team, color)
		)
		
	else:
		target.take_damage(
			attack_damage,
			Utils.create_hit_by(player, self.get_path(), team, color)
		)
	
	
func _on_Tween_dead_tween_completed(object, key):
	emit_signal("on_dead", self)
	
	
func display_player_name(_show : bool):
	.display_player_name(_show)
	_owner.visible = _show

func _on_VisibilityNotifier_screen_entered():
	_pivot.visible = true
	
func _on_VisibilityNotifier_screen_exited():
	_pivot.visible = false
	
	
func break_random_part():
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







