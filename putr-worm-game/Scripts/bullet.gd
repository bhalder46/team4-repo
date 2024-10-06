extends Area2D

@export var speed = 2000.0  # Adjust speed as needed
var direction = Vector2.ZERO

func _ready():
	set_process(true)  # Enable the process function
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))  # Use a Callable for the connection

func set_direction(target_position: Vector2):
	direction = (target_position).normalized()  # Use the direction set from the player

func _process(delta):
	global_position += direction * speed * delta  # Move in the direction set

func _on_Area2D_body_entered(body):
	if body.is_in_group("tilemap"):  # Check if the colliding body is in the group 'tilemap'
		queue_free()  # Free this node when collision occurs with a 'tilemap'
