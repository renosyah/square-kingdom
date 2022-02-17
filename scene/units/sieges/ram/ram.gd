extends Unit

const MAX_BODY_BREAK = 4

onready var _owner = $owner
onready var _hp_bar = $hpBar
onready var _pivot = $pivot
onready var _tween = $Tween
onready var _tween_dead = $Tween_dead
onready var _audio = $AudioStreamPlayer3D

onready var turn_speed = speed * 2

var _ram_weapon
var _wheels

############################################################
# multiplayer func
# multiplayer func
func _network_timmer_timeout():
	._network_timmer_timeout()
	if not target:
		return
		
	if is_dead:
		return
		
	if is_master():
		rset_unreliable("_puppet_rotation", rotation)
	
puppet var _puppet_rotation: Vector3 setget _set_puppet_rotation
func _set_puppet_rotation(_val:Vector3):
	_puppet_rotation = _val
	
func _set_puppet_translation(_val :Vector3):
	._set_puppet_translation(_val)
	
	if is_dead:
		translation = _puppet_translation
		return
		
	_tween.interpolate_property(self,"translation", translation, _puppet_translation, 0.5)
	_tween.start()
	
remotesync func _set_facing_direction(_val : int):
	._set_facing_direction(_val)
	
remotesync func _set_walking_state(_val : bool):
	._set_walking_state(_val)
	
	for i in _wheels:
		if is_walking:
			i.rotate_wheel()
		else:
			i.stop_wheel()
	
remotesync func _take_damage(_damage : float, _hit_by: Dictionary):
	._take_damage(_damage, _hit_by)
	
	if is_dead:
		return
		
	#break_random_part()
	
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
	
	_audio.stream = load("res://assets/sound/explode3.wav")
	_audio.play()
	
	_tween_dead.interpolate_property(_pivot, "translation:y", _pivot.translation.y , -4, 5.0, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween_dead.start()
	
############################################################
func set_data(_data):
	# we override this shit!
	#.set_data(_data)
	type_unit = _data.type_unit
	attack_damage = _data.attack_damage
	capture_damage = _data.capture_damage
	attack_cooldown = _data.attack_cooldown
	range_attack = _data.range_attack
	speed = _data.speed
	hp = _data.hp
	max_hp = _data.max_hp
	team = _data.team 
	color = _data.color
	
# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	
	if not player.empty():
		_owner.set_message(player.name)
		
	_hp_bar.show_label(false)
	_hp_bar.set_hp_bar_color(color)
	_hp_bar.update_bar(hp,max_hp)
	_hp_bar.modulate.a = 0.0
	
	set_process(true)
	init_siege()
	
func init_siege():
	_ram_weapon =  $pivot/ram
	_wheels = [$pivot/wheel_1, $pivot/wheel_2, $pivot/wheel_3, $pivot/wheel_4,$pivot/wheel_5, $pivot/wheel_6]
	$pivot/flag.set_flag_color(color)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# we override this shit!
	#._process(delta)
	if is_dead:
		return
		
	# is a puppet
	if not is_master():
		rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, delta * 5)
		rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, delta * 5)
		rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, delta * 5)
		return
		
	var velocity = Vector3.ZERO
	var direction = Vector3.ZERO
	var distance_to_target = 0.0
	
	if is_instance_valid(target):
		direction = translation.direction_to(target.translation)
		distance_to_target = translation.distance_to(target.translation)
		
		transform_turning((Vector3(target.translation.x , translation.y ,target.translation.z)), delta)
		
		if not target.is_targetable(team):
			_check_is_walking(false)
			target = null
			
		elif distance_to_target > range_attack:
			_check_is_walking(true)
			translation.y -= (1.0 * delta) if translation.y > 0.0 else 0.0
			velocity = Vector3(direction.x, 0.0 , direction.z) * speed
			
		elif distance_to_target <= range_attack and _cooldown_timmer.is_stopped():
			_check_is_walking(false)
			perform_attack()
			_cooldown_timmer.start()
			
		
		var collide = move_and_collide(velocity * delta)
		if collide != null:
			_on_collide(collide.collider)
		
func transform_turning(direction, delta):
	var new_transform = transform.looking_at(direction, Vector3.UP)
	transform = transform.interpolate_with(new_transform, turn_speed * delta)
	
func perform_attack():
	.perform_attack()
	
	if not is_master():
		return
		
	if target is Building:
		target.capture(capture_damage, {node_path = self.get_path(), team = team, color = color})
	else:
		target.take_damage(attack_damage, {node_path = self.get_path(), team = team, color = color})
	
	
func _on_Tween_dead_tween_completed(object, key):
	emit_signal("on_dead", self)
	
	
func display_player_name(_show : bool):
	.display_player_name(_show)
	_owner.visible = _show

func _on_VisibilityNotifier_screen_entered():
	visible = true
	
func _on_VisibilityNotifier_screen_exited():
	visible = false
	
	
func break_random_part():
	var _body = _pivot.get_children()
	var broken = 0
	
	for i in _body:
		if not i.visible:
			broken += 1
	
	if broken > MAX_BODY_BREAK:
		return
		
	_body[randi() % _body.size()].visible = false


func spawn_explosive():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	explosive.scale = Vector3.ONE * 12
	add_child(explosive)
	explosive.translation = translation
	explosive.translation.y += 2







