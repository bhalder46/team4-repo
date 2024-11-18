extends Area2D

const Player = preload("res://Scripts/player.gd")  # Adjust the path to your Player script

@onready var collision_shape = $CollisionShape2D  # Adjust the path if necessary

# Function to detect when the player enters the spikes
func _on_body_entered(body: Node) -> void:
	if body is Player:  # Check if the colliding body is the player
		print("Player hit the spikes!")
		if not body.is_invincible and not body.is_dead:
			print("Player is not dead and not invincible, calling die()")
			body.die()  # Call the die function on the player
		else:
			print("Player is invincible or already dead, skipping die()")
		
