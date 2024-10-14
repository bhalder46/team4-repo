extends Camera2D

# How much the camera should move in response to the reticle
@export var camera_follow_strength: float = 0.2
# Maximum distance the camera can offset
@export var max_camera_offset: float = 500.0

@export var player: Node2D
@export var enable_camera_follow: bool = true  # Toggle for enabling or disabling camera follow logic

func _process(delta: float) -> void:
	
	if player == null:
		print("Player reference is missing")
		return

	# Get the global position of the player
	var player_position = player.global_position
	
	# Start with the camera target position being the player position
	var target_position = player_position
	
	if enable_camera_follow:
		# Get the global position of the reticle (in world space)
		var reticle_world_position = get_global_mouse_position()

		# Calculate the offset from the player to the reticle and apply camera_follow_strength
		var offset = (reticle_world_position - player_position) * camera_follow_strength

		# Clamp the offset length if it's too large
		if offset.length() > max_camera_offset:
			offset = offset.normalized() * max_camera_offset

		# Add the offset to the target position
		target_position += offset
	
	# Smoothly move the camera towards the target position
	global_position = lerp(global_position, target_position, 0.1)
