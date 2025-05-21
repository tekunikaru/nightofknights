class_name BaseEnemy extends CharacterBody2D

signal hit(damage: int, direction: Vector2)
signal aggro(state: bool)


@export_category("Enemy Properties")
@export var is_hostile: bool = false
@export var contact_damage: bool = true
@export var gravity_multiplier: float = 1
@export var damage_dealt: int = 50
@export var lifepoints: int = 100
@export var manapoints: int = 100

@export_category("Movement")
@export var spawn_position: Vector2 = Vector2.ZERO
@export var speed: int = 100
@export var walk_max_distance: int = 200
@export var target_position: Vector2 = position
@export var walk_timer: int = 5

@export_category("Aggro and Detection")
@export var player_in_range: bool = false
@export var player_in_sight: bool = false
@export var aggro_timer: int = 10

var flipped: bool = true
var level: Level = null
var player: Player = null
var last_player_pos: Vector2 = Vector2.ZERO

func _ready():
	$DetectionArea.body_shape_entered.connect(func(_ix,body,_six,_lsix):
		if (body is Player):
			player_in_sight = true
			aggro.emit(true)
	)
	$DetectionArea.body_shape_exited.connect(func(_ix,body,_six,_lsix):
		if (body is Player):
			player_in_sight = false
			aggro.emit(false)
	)
	$AttackArea.body_shape_entered.connect(func(_ix,body,_six,_lsix):
		if (body is Player):
			player_in_range = true
	)
	$AttackArea.body_shape_exited.connect(func(_ix,body,_six,_lsix):
		if (body is Player):
			player_in_range = false
	)
	hit.connect(func(damage,direction):
		lifepoints-=damage
		if lifepoints <= 0: die()
	)
	
	is_hostile = get_meta("hostile",false)
	
	$Sprite.play("Idle")	

func _process(_delta: float):
	if !level or !player:
		level = DataManagerInstance.runtime_storage.get("Level")
		player = DataManagerInstance.runtime_storage.get("Player")
		return
	if !is_on_floor():
		velocity.y += level.gravity * gravity_multiplier
	
	if is_hostile and player_in_sight:
		last_player_pos = player.position
		$AggroTimer.start(aggro_timer)
	elif $WalkTimer.is_stopped():
		target_position.x = position.x + (((randi()%walk_max_distance)*2)-walk_max_distance)
		$WalkTimer.start(walk_timer)
	
	if not $AggroTimer.is_stopped():
		target_position = last_player_pos
	
	if abs(position.x - target_position.x) >= 10 and not player_in_range:
		velocity.x = Vector2(target_position.x - position.x,0).normalized().x * speed * (2.2 if player_in_sight else 1.0)
		$Sprite.play("Walk")
		if (velocity.x > 0 and flipped) or (velocity.x < 0 and !flipped):
			flip()
	elif is_hostile and player_in_range:
		$Sprite.play("Attack")
		await $Sprite.animation_finished
		var knockback = Vector2(player.position-position).normalized() * speed
		player.hit.emit(damage_dealt,knockback)
		if player.lifepoints <= 0:
			is_hostile = false
			$AggroTimer.stop()
	else:
		$AggroTimer.stop()
		velocity.x = 0
		$Sprite.play("Idle")
	
	move_and_slide()

func flip():
	scale.y = -1 if flipped else 1
	rotation_degrees = 180 if flipped else 0
	flipped = !flipped
	$EntityInfo.scale.x = 1 if flipped else -1

func die():
	$Sprite.play("Death")
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	await get_tree().create_timer(0.3).timeout
