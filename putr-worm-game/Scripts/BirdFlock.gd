extends Node2D

# Speed in pixels per second
@export var speed: float = 100.0
# Duration to move before deleting the node (in seconds)
@export var move_duration: float = 10.0

# Time elapsed since movement started
var elapsed_time: float = 0.0

func _process(delta: float) -> void:
	# Move to the right
	if elapsed_time < move_duration:
		position.x += speed * delta
		elapsed_time += delta
	else:
		# Delete the node after 10 seconds
		queue_free()
