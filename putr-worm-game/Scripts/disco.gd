extends PointLight2D

var pulse_min = 5  # Minimum energy value
var pulse_max = 6  # Maximum energy value
var pulse_speed = 2.0  # Speed at which the energy pulses
var color_timer = 0.0
var current_energy = pulse_min  # Renamed the variable to avoid conflict
var pulse_direction = 1  # 1 for increasing, -1 for decreasing

# Define the color sequence (Red, Blue, Green, Orange, Yellow, Pink)
var color_sequence = [
	Color(1, 0, 0),  # Red
	Color(0, 0, 1),  # Blue
	Color(0, 1, 0),  # Green
	Color(1, 0.5, 0),  # Orange
	Color(1, 1, 0),  # Yellow
	Color(1, 0, 1)   # Pink
]

var current_color_index = 0  # Start from the first color in the sequence

func _ready():
	# Set the initial color
	set_next_color()

func _process(delta):
	# Update color every 0.5 seconds
	color_timer += delta
	if color_timer >= 0.5:
		set_next_color()
		color_timer = 0.0

	# Pulse energy
	current_energy += pulse_direction * pulse_speed * delta
	if current_energy >= pulse_max or current_energy <= pulse_min:
		pulse_direction = -pulse_direction  # Reverse direction when the energy hits the limits

	energy = current_energy  # Directly set the energy property

# Function to change the point light color to the next in the sequence
func set_next_color():
	# Set the color based on the current index in the sequence
	color = color_sequence[current_color_index]
	
	# Move to the next color in the sequence, looping back to the start if necessary
	current_color_index = (current_color_index + 1) % color_sequence.size()
