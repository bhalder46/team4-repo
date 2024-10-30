# AntigravityArea.gd
extends Area2D

# Adjust gravity scale to zero when entering and reset on exit
func _on_body_entered(body):
	# Check if the entered body is the player (adjust if player has a specific name or type)
	if body.name == "Player":
		body.gravity_scale = 0  # Turn off gravity for the player

func _on_body_exited(body):
	# Reset gravity when the player exits the area
	if body.name == "Player":
		body.gravity_scale = 1  # Restore gravity for the player
