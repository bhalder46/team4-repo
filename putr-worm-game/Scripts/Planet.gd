extends AnimatedSprite2D

# Export variables for customization in the editor
@export var speed: float = 1.0  # Speed of orbit
@export var orbit_distance: float = 5.0  # Horizontal distance from the center
@export var orbit_height: float = 2.0  # Vertical height of the orbit arc
@export var scale_strength: float = 0.5  # Factor by which the scale changes
@export var background_sorting_layer: String = "Background"  # Name of the background sorting layer
@export var foreground_sorting_layer: String = "Foreground"  # Name of the foreground sorting layer

# Declare variables for use in the script
var center_position: Vector2  # Center position for the orbit
var initial_scale: float  # Initial scale of the sprite
var elapsed_time: float = 0.0  # Track elapsed time for orbit calculation

func _ready():
	# Set the center position to the initial position of the sprite
	center_position = global_position

	# Store the initial scale of the sprite
	initial_scale = scale.x

	# Connect the area entered signal

func _process(delta):
	# Update the elapsed time
	elapsed_time += delta

	# Calculate the position along the orbit arc using sine and cosine functions
	var x = center_position.x + cos(elapsed_time * speed) * orbit_distance  # Horizontal movement
	var y = center_position.y + sin(elapsed_time * speed) * orbit_height   # Vertical movement

	# Update the position of the planet
	global_position = Vector2(x, y)  # Set the new global position

	# Change sorting layer based on y position
	if y < center_position.y:
		z_index = -8  # Background
	else:
		z_index = 50  # Foreground

	# Always disable monitoring when in negative z index
	$Area2D.monitoring = z_index > 0

	# Calculate scale based on vertical position
	var scale_factor = initial_scale + (sin(elapsed_time * speed) * scale_strength)

	# Apply the scale to the sprite
	scale = Vector2(scale_factor, scale_factor)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):  # Check if the colliding body is the player
		body.die()  # Call the die function on the player
