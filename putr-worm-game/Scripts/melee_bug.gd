extends CharacterBody2D

# Movement speed
var speed: float = 100.0
# Patrol distance from the starting position
var patrol_distance: float = 20.0

# Starting position
var start_position: Vector2

# Reference to the AnimatedSprite2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Store the starting position
	start_position = position

	# Play the walk animation
	animated_sprite.play("walk")

func _process(delta: float):
	# Calculate the current position relative to the starting position
	var offset = position.x - start_position.x

	# Move the enemy
	if offset < patrol_distance:
		velocity.x = speed  # Move right
	else:
		velocity.x = -speed  # Move left

	# Flip the sprite based on the movement direction
	animated_sprite.flip_h = velocity.x < 0  # Flip if moving left

	# Call the move_and_slide method to move the CharacterBody2D
	move_and_slide()

	# Check if the enemy has moved beyond the patrol distance
	if abs(offset) >= patrol_distance:
		# Move back toward the starting position
		velocity.x *= -1
