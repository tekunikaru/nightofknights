class_name Player extends CharacterBody2D

signal hit(damage:int,direction:Vector2)

@export_category("Player Properties")
@export var lifepoints: int = 100
@export var manapoints: int = 100
@export var staminapoints: int = 100
@export var supermode: bool
@export var move_speed: float = 200
@export var jump_force: float = 800
@export var gravity_multiplier: float = 1
@export var max_jump_count: int = 2
var jump_count: int = 2
var level: Level = null
var is_grounded : bool = false

func _ready() -> void:
	spawn()
	DataManagerInstance.runtime_storage.set("Player",self)
	hit.connect(func(damage,direction):
		velocity = direction
		move_and_slide()
		lifepoints -= damage
		if lifepoints <= 0:
			die()
	)

func _process(_delta):
	if !level:
		level = DataManagerInstance.runtime_storage.get("Level")
		return
	
	if !is_on_floor():
		velocity.y += level.gravity * gravity_multiplier
	else:
		jump_count = max_jump_count
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() and !supermode:
			jump()
			velocity.y = -jump_force
		elif supermode and jump_count > 0:
			jump()
			jump_count -= 1
			velocity.y = -jump_force
	
	var inputAxis = Input.get_axis("move_left", "move_right")
	velocity = Vector2(inputAxis * move_speed, velocity.y)
	move_and_slide()

func die():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	await get_tree().create_timer(0.3).timeout

func spawn():
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 

func jump():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	$Jump.play()
