extends PointLight2D

# Flickering parameters
@export var min_energy: float = 0.7  # Minimum light energy
@export var max_energy: float = 1.5  # Maximum light energy
@export var flicker_speed: float = 0.09  # Speed of flickering

# Internal variable to keep track of the time
var time_passed: float = 0.0

func _process(delta: float) -> void:
	# Update the time passed
	time_passed += delta * flicker_speed

	var flicker_value = lerp(min_energy, max_energy, (sin(time_passed * 5) + 1) / 2)
	self.energy = flicker_value
