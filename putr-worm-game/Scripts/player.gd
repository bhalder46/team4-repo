extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -250.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Apply gravity if the player is not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get movement direction
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the sprite based on movement direction
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Play the appropriate animation based on movement state
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		# Check if player is jumping or falling
		if velocity.y < 0:
			animated_sprite.play("jump")
		elif velocity.y > 0:
			animated_sprite.play("fall")

	# Move left or right
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		# Smoothly stop when no input is provided
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Move the character and slide along surfaces
	move_and_slide()
