class_name Player extends CharacterBody2D

@export_category("Player Properties")
@export var lifepoints: float = 1
@export var manapoints: float = 1
@export var staminapoints: float = 1
@export var supermode: bool
@export var move_speed: float = 200
@export var jump_force: float = 800
@export var gravity_multiplier: float = 1
@export var max_jump_count: int = 2
var jump_count: int = 2
var level: Level = null
var is_grounded : bool = false

func _ready() -> void:
	respawn_tween()
	DataManagerInstance.runtime_storage.set("Player",self)

func _process(_delta):
	if !level:
		level = DataManagerInstance.runtime_storage.get("Level")
	if !is_on_floor():
		velocity.y += level.gravity * gravity_multiplier
	elif is_on_floor():
		jump_count = max_jump_count
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() and !supermode:
			jump_tween()
			velocity.y = -jump_force
		elif supermode and jump_count > 0:
			jump_tween()
			jump_count -= 1
			velocity.y = -jump_force
	
	var inputAxis = Input.get_axis("move_left", "move_right")
	velocity = Vector2(inputAxis * move_speed*direction_markiplier(), velocity.y)
	move_and_slide()

func direction_markiplier():
	return 1

func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	await get_tree().create_timer(0.3).timeout
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	$Jump.play()
