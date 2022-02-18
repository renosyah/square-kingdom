extends KinematicBody
class_name Unit

const dead_sounds = [
	"res://assets/sound/maledeath1.wav",
	"res://assets/sound/maledeath2.wav",
	"res://assets/sound/maledeath3.wav",
	"res://assets/sound/maledeath4.wav"
]

signal on_ready(_unit)
signal on_dead(_unit)
signal on_take_damage(_unit, _hit_by, _damage, _hp, _max_hp)

# base
var player = {}
var type_unit = ""

# weapons
var primary_weapon_scene = "res://scene/weapon/melee/sword/sword.tscn"
var secondary_weapon_scene = "res://scene/weapon/shield/shield.tscn"

# armor
var helm = ""
var armor = ""

# attack
var target = null # other unit node
var attack_damage = 4.0
var capture_damage = 10.0
var attack_cooldown = 1.2
var range_attack = 1.4

# mobility
var is_walking = false
var speed = 4.0
var facing_direction = 1

# vitality
var is_dead = false
var hp : float = 10.0
var max_hp : float = 10.0

# tag
var team : String = ""
var color : Color = Color.white

# hit
var hit_by : Dictionary = {player = {}, node_path = "", team = "", color = Color.white}

# misc
var _network_timmer : Timer = null
var _cooldown_timmer : Timer = null
var _idle_timmer : Timer = null

############################################################
# multiplayer func
func _network_timmer_timeout():
	if not target:
		return
		
	if is_dead:
		return
		
	if is_master():
		rset_unreliable("_puppet_translation", translation)
	
puppet var _puppet_translation :Vector3 setget _set_puppet_translation
func _set_puppet_translation(_val :Vector3):
	_puppet_translation = _val
		
remotesync func _set_facing_direction(_val : int):
	facing_direction = _val
	
remotesync func _set_walking_state(_val : bool):
	is_walking = _val
	
remotesync func _take_damage(_damage : float, _hit_by: Dictionary):
	hp -= _damage
	hit_by = _hit_by
	
	if is_dead:
		return
		
	if hp < 1:
		dead()
		
	emit_signal("on_take_damage", self, hit_by, _damage, hp, max_hp)
	
remotesync func _perform_attack():
	if is_dead:
		return
		
	
remotesync func _dead():
	is_dead = true
	set_process(false)
	
############################################################
func set_data(_data):
	type_unit = _data.type_unit
	primary_weapon_scene = _data.primary_weapon_scene
	secondary_weapon_scene = _data.secondary_weapon_scene
	helm = _data.helm
	armor = _data.armor
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
	set_process(is_master())
	
	if not is_master():
		return
		
	if not _network_timmer:
		_network_timmer = Timer.new()
		_network_timmer.wait_time = 0.4
		_network_timmer.connect("timeout", self , "_network_timmer_timeout")
		_network_timmer.autostart = true
		add_child(_network_timmer)
		
	if not _cooldown_timmer:
		_cooldown_timmer = Timer.new()
		_cooldown_timmer.wait_time = attack_cooldown
		_cooldown_timmer.autostart = false
		_cooldown_timmer.one_shot = true
		add_child(_cooldown_timmer)
		
	if not _idle_timmer:
		_idle_timmer = Timer.new()
		_idle_timmer.wait_time = rand_range(2,5)
		_idle_timmer.connect("timeout", self , "_idle_timmer_timeout")
		_idle_timmer.autostart = true
		add_child(_idle_timmer)
		
	emit_signal("on_ready", self)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_dead:
		return
		
	# is a puppet
	if not is_master():
		return
		
	var velocity = Vector3.ZERO
	var direction = Vector3.ZERO
	var distance_to_target = 0.0
	
	if is_instance_valid(target):
		direction = translation.direction_to(target.translation)
		distance_to_target = translation.distance_to(target.translation)
		_check_facing_direction(direction.x)
		
		if not target.is_targetable(team):
			_check_is_walking(false)
			target = null
			
		elif distance_to_target > range_attack:
			_check_is_walking(true)
			velocity = Vector3(direction.x, 0.0 , direction.z) * speed
			
		elif distance_to_target <= range_attack and _cooldown_timmer.is_stopped():
			perform_attack()
			_cooldown_timmer.start()
		
		var collide = move_and_collide(velocity * delta)
		if collide != null:
			_on_collide(collide.collider)
		
		
func take_damage(_damage : float, _hit_by: Dictionary):
	if not is_master():
		return
		
	var _aggresor = get_node_or_null(_hit_by.node_path)
	if is_instance_valid(_aggresor):
		target = _aggresor
		
	rpc("_take_damage", _damage, _hit_by)
	
func dead():
	if not is_master():
		return
		
	rpc("_dead")

func perform_attack():
	if not is_master():
		return
		
	rpc("_perform_attack")
	
func _check_facing_direction(_direction : float):
	var dir = 1 if _direction > 0.0 else -1
	if facing_direction != dir:
		rpc("_set_facing_direction" , dir)
		
func _check_is_walking(_is_walking):
	if is_walking != _is_walking:
		is_walking = _is_walking
		rpc("_set_walking_state", _is_walking)
		
func display_player_name(_show : bool):
	pass
	
func _idle_timmer_timeout():
	if not is_master():
		return
		
	if not is_instance_valid(target):
		emit_signal("on_ready", self)
		return
		
	if not target.is_targetable(team):
		emit_signal("on_ready", self)
	
func is_master() -> bool:
	if not get_tree().network_peer:
		return false
	
	if not is_network_master():
		return false
		
	return true
	
func is_targetable(_team) -> bool:
	return team != _team and not is_dead
	
func _on_collide(body):
	if not is_instance_valid(body):
		return
		
	if body is StaticBody:
		return
		
	if not body.is_targetable(team):
		return
		
	target = body
	
	#_check_is_walking(false)
	#target = null







