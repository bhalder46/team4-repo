extends Area2D

# Signal to notify when the player activates the checkpoint
signal checkpoint_activated(position: Vector2)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("players"):  # Assuming the player is in the "Player" group
		emit_signal("checkpoint_activated", global_position)  # Emit the signal with the checkpoint's position
		print("Checkpoint")
