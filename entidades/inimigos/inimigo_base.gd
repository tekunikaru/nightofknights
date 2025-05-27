class_name BaseEnemy extends CharacterBody2D

signal hit(damage: int, direction: Vector2)
signal aggro(state: bool)


@export_category("Enemy Properties")
@export var is_hostile: bool = false
@export var contact_damage: bool = true
@export var gravity_multiplier: float = 1
@export var damage_dealt: int = 20
@export var lifepoints: int = 100
@export var manapoints: int = 100

@export_category("Movement")
@export var spawn_position: Vector2 = Vector2.ZERO
@export var speed: int = 100
@export var walk_max_distance: int = 200
@export var target_position: Vector2 = position
@export var walk_timer: int = 8

@export_category("Aggro and Detection")
@export var player_in_range: bool = false
@export var player_in_sight: bool = false
@export var aggro_timer: int = 10

var flipped: bool = true
var level: Level = null
var player: Player = null
var last_player_pos: Vector2 = Vector2.ZERO
var avoid_sfx: bool = false

func _ready():
	$DetectionArea.body_shape_entered.connect(func(_ix,body,_six,_lsix):
		if (body is Player and is_hostile):
			player_in_sight = true
			aggro.emit(true)
	)
	$DetectionArea.body_shape_exited.connect(func(_ix,body,_six,_lsix):
		if (body is Player and is_hostile):
			player_in_sight = false
			aggro.emit(false)
	)
	$AttackArea.body_shape_entered.connect(func(_ix,body,_six,_lsix):
		if (body is Player and is_hostile):
			player_in_range = true
	)
	$AttackArea.body_shape_exited.connect(func(_ix,body,_six,_lsix):
		if (body is Player and is_hostile):
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
		$WalkTimer.start(walk_timer + (randi() % 5) -2 )
	
	if not $AggroTimer.is_stopped():
		target_position = last_player_pos
	
	if abs(position.x - target_position.x) >= 10 and not player_in_range:
		velocity.x = Vector2(target_position.x - position.x,0).normalized().x * speed * (2.2 if player_in_sight else 1.0)
		$Sprite.play("Walk")
		if (velocity.x > 0 and flipped) or (velocity.x < 0 and !flipped):
			flip()
		if (has_node("Step")): if ($Sprite.frame == 1 or $Sprite.frame == 6) and not avoid_sfx:
			avoid_sfx = true
			$Step.play()
		elif not ($Sprite.frame == 1 or $Sprite.frame == 6):
			avoid_sfx = false
	elif is_hostile and player_in_range:
		if player.lifepoints - damage_dealt <= 0 and $Sprite.animation != "Attack":
			Engine.time_scale = 0.2
			get_tree().create_timer(0.6).connect("timeout",func():
				Engine.time_scale = 1
			)
		if $Hit.playing:
			return
		$Hit.play()
		$Sprite.play("Attack")
		await $Sprite.animation_finished
		if player_in_range and $Sprite.animation == "Attack":
			$Sprite.play("Idle")
			#var knockback = Vector2(player.position-position).normalized() * speed
			player.hit.emit(damage_dealt,Vector2.ZERO)
			if player.lifepoints <= 0:
				is_hostile = false
				player_in_range = false
				player_in_sight = false
				$AggroTimer.stop()
	else:
		$AggroTimer.stop()
		velocity.x = 0
		$Sprite.play("Idle")
	
	move_and_slide()

func flip():
	if flipped:
		scale.y = -1
		rotation_degrees = 180
		$EntityInfo.scale.x = -1
	else:
		scale.y = 1
		rotation_degrees = 0
		$EntityInfo.scale.x = 1
	
	flipped = !flipped

func die():
	$Sprite.play("Death")
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	await get_tree().create_timer(0.3).timeout
