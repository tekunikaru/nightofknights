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
var avoid_sfx: bool = false

func _ready() -> void:
	spawn()
	DataManagerInstance.runtime_storage.set("Player",self)
	hit.connect(func(damage,direction):
		velocity = direction
		move_and_slide()
		lifepoints -= damage
		$HUD/Lifebar.value = lifepoints
		if lifepoints <= 0:
			var tween = create_tween()
			tween.tween_property($Camera2D, "zoom", Vector2(1.5, 1.5), 0.6)
			$Sprite.play("Death")
			self.set_collision_layer_value(3,false)
	)
	$IdleAnimation.timeout.connect(func():if $Sprite.animation == "Idle":
		$Sprite.frame = randi() % 1
		$Sprite.flip_h = randi() % 1 == 1
		$IdleAnimation.start(randi() % 10 + 5)
	)

func _physics_process(_delta):
	if !level:
		level = DataManagerInstance.runtime_storage.get("Level")
		return
	
	if !is_on_floor():
		velocity.y += level.gravity * gravity_multiplier * Engine.time_scale
		if $Sprite.animation != "Jump" and $Sprite.animation != "Death":
			$Sprite.play("Fall")
	elif $Sprite.animation != "Death":
		jump_count = max_jump_count
		if velocity.x != 0:
			$Sprite.play("Walk")
			if ($Sprite.frame == 1 or $Sprite.frame == 6) and not avoid_sfx:
				avoid_sfx = true
				$Step.play()
			elif not ($Sprite.frame == 1 or $Sprite.frame == 6):
				avoid_sfx = false
			$Sprite.flip_h = velocity.x < 0
		elif velocity.x == 0 and $Sprite.animation != "Idle":
			$Sprite.play("Idle")
			$Step.play()
	
	if $Sprite.animation == "Death":
		return
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() and !supermode:
			jump()
			velocity.y = -jump_force
		elif supermode and jump_count > 0:
			jump()
			jump_count -= 1
			velocity.y = -jump_force
	
	velocity = Vector2(Input.get_axis("move_left", "move_right") * move_speed, velocity.y)
	move_and_slide()

func spawn():
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 

func jump():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	$Jump.play()
	$Sprite.play("Jump")
	await $Sprite.animation_finished
	$Sprite.play("Fall")
