extends Area2D

const Player = preload("res://Scripts/player.gd")  # Adjust the path to your Player script

@onready var collision_shape = $CollisionShape2D  # Adjust the path if necessary

# Function to detect when the player enters the spikes
func _on_body_entered(body: Node) -> void:
	if body is Player:  # Check if the colliding body is the player
		body.die()  # Call the die function on the player
