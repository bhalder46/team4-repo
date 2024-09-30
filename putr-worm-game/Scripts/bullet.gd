extends Area2D

@export var speed = 2000.0  # Adjust speed as needed
var direction = Vector2.ZERO

func _ready():
	set_process(true)  # Enable the process function

func set_direction(target_position: Vector2):
	direction = (target_position).normalized()  # Use the direction set from the player

func _process(delta):
	position += direction * speed * delta  # Move in the direction set
	
