extends Sprite2D  # or Sprite if you used a Sprite node

func _process(delta: float) -> void:
	# Update the position to follow the mouse
	position = get_global_mouse_position()
