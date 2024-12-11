extends CharacterBody2D

# Speed and movement settings
var move_speed: float = 100
var direction: int = 1  # 1 for right, -1 for left
var gravity: float = 400  # Gravity strength

# Raycasts for detecting collisions
@onready var raycast_left = $RayCast_left
@onready var raycast_right = $RayCast_right

func _ready():
	# Ensure raycasts are enabled
	raycast_left.enabled = true
	raycast_right.enabled = true

func _process(delta):
	# Apply gravity every frame
	velocity.y += gravity * delta  # Gravity affects the vertical velocity

	# Check for collisions on left or right
	if raycast_right.is_colliding():
		# Flip direction to left if colliding on the right
		direction = -1
		print("Raycast Right Collision Detected")  # Debug statement for right collision
	elif raycast_left.is_colliding():
		# Flip direction to right if colliding on the left
		direction = 1
		print("Raycast Left Collision Detected")  # Debug statement for left collision

	# Set the horizontal velocity
	velocity.x = move_speed * direction

	# Move the character with the updated velocity
	move_and_slide()
