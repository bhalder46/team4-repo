extends Node2D 

# Bobbing parameters
@export var bobbing_distance: float = 10.0  # The distance to bob up and down
@export var bobbing_speed: float = 2.0       # Speed of the bobbing

var time_passed: float = 0.0
var initial_position: Vector2

func _ready() -> void:
	initial_position = position

func _process(delta: float) -> void:
	# Update the time passed
	time_passed += delta * bobbing_speed
	
	# Calculate the new Y offset using sine for smooth bobbing
	var y_offset = sin(time_passed) * bobbing_distance

	# Update the position of the node by adding the y_offset to the initial position
	position.y = initial_position.y + y_offset
