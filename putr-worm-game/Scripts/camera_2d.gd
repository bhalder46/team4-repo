extends Camera2D

# Camera follow parameters
@export var camera_follow_strength: float = 0.2
@export var max_camera_offset: float = 500.0
@export var player: Node2D
@export var enable_camera_follow: bool = true  # Toggle for enabling or disabling camera follow logic

# Screenshake parameters
@export var shake_intensity: float = 10.0  # How much the camera shakes
@export var shake_duration: float = 0.2  # Duration of the shake in seconds

var shake_timer: float = 0.0  # Internal timer for the shake effect
var is_shaking: bool = false  # Whether the screen is currently shaking

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
	
	# Apply screenshake if active
	if is_shaking:
		shake_timer -= delta
		if shake_timer <= 0.0:
			is_shaking = false
		else:
			var shake_offset = Vector2(randi_range(-shake_intensity, shake_intensity), randi_range(-shake_intensity, shake_intensity))
			target_position += shake_offset
	
	# Smoothly move the camera towards the target position
	global_position = lerp(global_position, target_position, 0.1)

# Call this method to trigger a screenshake effect
func screenshake() -> void:
	is_shaking = true
	shake_timer = shake_duration
