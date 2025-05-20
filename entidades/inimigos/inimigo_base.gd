class_name BaseEnemy extends CharacterBody2D

@export var is_hostile: bool = false
@export var contact_damage:bool = true
@export var gravity_multiplier : float = 1

var level: Level = null
var player: Player = null
var speed: int = 100
var last_player_pos: Vector2 = Vector2.ZERO
@export var target_position: Vector2 = position
@export var following_player:bool = false
var random_walk_timer: float = 5
var random_walk_max_distance: int = 200

var nearby_entities = []
var seen_entities = []

func _ready():
	$DetectionArea.body_shape_entered.connect(update_nearby_entities)
	$DetectionArea.body_shape_exited.connect(update_nearby_entities)
	$Sprite.play("Idle")

func update_nearby_entities(_entity):
	nearby_entities = $DetectionArea.get_overlapping_bodies()

func _process(delta: float):
	if !level or !player:
		level = DataManagerInstance.runtime_storage.get("Level")
		player = DataManagerInstance.runtime_storage.get("Player")
	if !is_on_floor():
		velocity.y += level.gravity * gravity_multiplier
	
	if is_hostile and following_player:
		last_player_pos = player.position
		target_position = last_player_pos
	elif $Timer.is_stopped():
		target_position.x = position.x + (((randi()%random_walk_max_distance)*2)-random_walk_max_distance)
		$Timer.start(random_walk_timer)

	if abs(position.x - target_position.x) >= 50:
		velocity.x = Vector2(target_position.x - position.x,0).normalized().x * speed
	else:
		velocity.x = 0
	move_and_slide()
