extends AnimatedSprite2D

# Minimum and maximum speed scale values
@export var min_speed_scale: float = 0.5
@export var max_speed_scale: float = 1.5

func _ready():
	# Randomize the speed scale within the defined range
	speed_scale = randf_range(min_speed_scale, max_speed_scale)
