extends Camera2D

# Camera follow parameters
@export var camera_follow_strength: float = 0.2
@export var max_camera_offset: float = 500.0
@export var player: Node2D
@export var enable_camera_follow: bool = true  # Toggle for enabling or disabling camera follow logic

# Screenshake parameters
@export var shake_intensity: float = 18.0  # How much the camera shakes
@export var shake_duration: float = 0.2  # Duration of the shake in seconds

# Long screenshake parameters
@export var long_shake_intensity: float = 25.0  # Intensity of the long shake
@export var long_shake_duration: float = 4.0  # Duration of the long shake

var shake_timer: float = 0.0  # Internal timer for the shake effect
var is_shaking: bool = false  # Whether the screen is currently shaking
var shake_intensity_active: float = 0.0  # Active intensity for the current shake effect

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
			shake_intensity_active = 0.0  # Reset active intensity when shake stops
		else:
			var shake_offset = Vector2(randi_range(-shake_intensity_active, shake_intensity_active), randi_range(-shake_intensity_active, shake_intensity_active))
			target_position += shake_offset
	
	# Smoothly move the camera towards the target position
	global_position = lerp(global_position, target_position, 0.1)

# Call this method to trigger a short screenshake effect
func screenshake() -> void:
	is_shaking = true
	shake_timer = shake_duration
	shake_intensity_active = shake_intensity

# Call this method to trigger a longer, more intense screenshake effect
func screenshake_long() -> void:
	is_shaking = true
	shake_timer = long_shake_duration
	shake_intensity_active = long_shake_intensity
