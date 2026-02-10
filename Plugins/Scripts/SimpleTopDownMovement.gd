extends CharacterBody2D

@export var speed: float = 30

func _physics_process(delta: float) -> void:
	var move_direction = Vector2.ZERO

	if Input.is_action_pressed("up"):
		move_direction.y -= 1
	if Input.is_action_pressed("down"):
		move_direction.y += 1
	if Input.is_action_pressed("left"):
		move_direction.x -= 1
	if Input.is_action_pressed("right"):
		move_direction.x += 1

	velocity = move_direction.normalized() * speed
	move_and_slide()
