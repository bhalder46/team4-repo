extends PointLight2D

# Variables to configure the pulse effect
@export var min_energy: float = 0.5
@export var max_energy: float = 1.5
@export var pulse_duration: float = 2.0 # Time in seconds for a full pulse cycle

# Internal variables
var _time_elapsed: float = 0.0

func _process(delta: float) -> void:
	# Update time
	_time_elapsed += delta

	# Calculate the energy value using a sine wave for smooth pulsing
	var pulse_progress = fmod(_time_elapsed / pulse_duration, 1.0) # Normalized time
	energy = lerp(min_energy, max_energy, (sin(pulse_progress * TAU) + 1.0) / 2.0)
