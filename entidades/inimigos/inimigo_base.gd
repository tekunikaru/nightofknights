class_name BaseEnemy extends CharacterBody2D

@export var is_hostile: bool = false
@export var contact_damage:bool = true
@export var gravity_multiplier : float = 1
@export var last_checkpoint: Vector2 = Vector2.ZERO
@export var spawn_position: Vector2 = Vector2.ZERO

var flipped: bool = true
var level: Level = null
var player: Player = null
var speed: int = 100
var last_player_pos: Vector2 = Vector2.ZERO
@export var target_position: Vector2 = position
var random_walk_timer: float = 5
var random_walk_max_distance: int = 200

@export var player_in_range: bool = false
@export var following_player: bool = false

func _ready():
	$DetectionArea.body_shape_entered.connect(func(_ix,body,_six,_lsix):
		player_in_range = body is Player
	)
	$DetectionArea.body_shape_exited.connect(func(_ix,body,_six,_lsix):
		player_in_range = body is not Player
	)
	is_hostile = get_meta("hostile",false)
	
	$Sprite.play("Idle")	

func _process(_delta: float):
	if !level or !player:
		level = DataManagerInstance.runtime_storage.get("Level")
		player = DataManagerInstance.runtime_storage.get("Player")
	if !is_on_floor():
		velocity.y += level.gravity * gravity_multiplier
	
	if is_hostile and player_in_range:
		following_player = true
		last_player_pos = player.position
	elif $Timer.is_stopped():
		target_position.x = position.x + (((randi()%random_walk_max_distance)*2)-random_walk_max_distance)
		$Timer.start(random_walk_timer)
	if following_player:
		target_position = last_player_pos

	if abs(position.x - target_position.x) >= 10:
		print(abs(position.x - target_position.x))
		velocity.x = Vector2(target_position.x - position.x,0).normalized().x * speed * (1.5 if player_in_range else 1)
		$Sprite.play("Walk")
		if (velocity.x > 0 and flipped) or (velocity.x < 0 and !flipped):
			flip()
	else:
		following_player = false
		velocity.x = 0
		$Sprite.play("Idle")
	
	move_and_slide()

func flip():
	scale.y = -1 if flipped else 1
	rotation_degrees = 180 if flipped else 0
	flipped = !flipped
