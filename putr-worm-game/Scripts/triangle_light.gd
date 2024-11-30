extends Node2D

# Bobbing parameters
@export var bobbing_distance: float = 10.0  # Distance to bob
@export var bobbing_speed: float = 2.0      # Bobbing speed
@export var bobbing_horizontal: bool = false  # Enable horizontal bobbing

var time_passed: float = 0.0
var initial_position: Vector2

func _ready() -> void:
	initial_position = position

func _process(delta: float) -> void:
	time_passed += delta * bobbing_speed
	
	var offset = sin(time_passed) * bobbing_distance
	
	if bobbing_horizontal:
		position.x = initial_position.x + offset
	else:
		position.y = initial_position.y + offset
