extends PointLight2D

# Flickering parameters
@export var min_energy: float = 0.7  # Minimum light energy
@export var max_energy: float = 1.5  # Maximum light energy
@export var min_flicker_speed: float = 0.2  # Minimum flicker speed
@export var max_flicker_speed: float = 0.6  # Maximum flicker speed
@export var toggle_interval: float = 0.0  # Interval in seconds to toggle the light on and off

# Internal variables to keep track of time
var time_passed: float = 0.0
var toggle_time: float = 0.0
var is_light_enabled: bool = true  # Track if light is currently enabled

func _process(delta: float) -> void:
	# Randomize flicker speed within the specified range each frame
	var flicker_speed = randf_range(min_flicker_speed, max_flicker_speed)

	# Update time for flickering effect
	time_passed += delta * flicker_speed

	# Calculate flickering energy value
	var flicker_value = lerp(min_energy, max_energy, (sin(time_passed * 5) + 1) / 2)
	self.energy = flicker_value if is_light_enabled else 0.0

	# Update toggle time and switch light on/off at intervals
	toggle_time += delta
	if toggle_time >= toggle_interval:
		is_light_enabled = !is_light_enabled
		toggle_time = 0.0
