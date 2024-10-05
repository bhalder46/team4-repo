extends Node2D

# Variables to control the parallax effect
@export var parallax_speeds = [0.2, 0.5, 0.8]  # Adjust for each background layer

# Reference to the camera node
@export var camera: Camera2D

# Called every frame
func _process(delta: float) -> void:
	# Get the camera's position (In Godot 4, it's a property)
	var camera_pos = Camera2D.position

	# Loop through the background layers
	for i in range(get_child_count()):
		var layer = get_child(i)

		# Apply parallax movement to each background layer
		var parallax_speed = parallax_speeds[i]
		layer.position = camera_pos * parallax_speed
