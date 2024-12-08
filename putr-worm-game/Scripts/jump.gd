extends AnimatedSprite2D

# Variables for the jump
@export var jump_height: float = 100.0 # How high the sprite jumps
@export var jump_distance: float = 200.0 # How far the sprite jumps
@export var jump_duration: float = 1.0 # Duration of the jump (seconds)
@export var gravity: float = 300.0 # Gravity strength

# Internal variables
var velocity: Vector2 = Vector2()
var direction: int = 1 # 1 for right, -1 for left
var elapsed_time: float = 0.0

func _ready():
	# Start jumping behavior
	set_physics_process(true)
	play("new_animation_2") # Play the initial animation

func _physics_process(delta: float):
	elapsed_time += delta
	if elapsed_time >= jump_duration:
		# Reset time and switch direction
		elapsed_time = 0.0
		direction *= -1
		flip_h = direction < 0

		# Play the jump animation
		play("new_animation_2")

	# Calculate horizontal position based on time and direction
	var t = elapsed_time / jump_duration
	var x = direction * jump_distance * t
	var y = -4 * jump_height * t * (1 - t) # Parabolic motion

	# Update sprite position
	position += Vector2(x, y) * delta
