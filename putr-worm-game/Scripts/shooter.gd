extends Marker2D

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 500.0
@export var spawn_rate: float = 0.5  # Time in seconds between each spawn (2 bullets per second)

func _ready():
	# Start shooting projectiles at the defined rate
	_shoot_projectile_repeatedly()

func shoot_projectile():
	if projectile_scene:
		# Adjusted spawn position below the Marker2D (shooting downwards)
		var spawn_position = global_position - Vector2(0, 0)  # Spawn 20 units below

		# Instantiate the projectile
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)  # Add the projectile to the parent of the Marker2D
		projectile.global_position = spawn_position  # Set the spawn position of the projectile

		# Adjusted direction: shoot straight down (Vector2(0, 1) represents downward direction)
		var direction = Vector2(0, 1)  # Shooting directly downwards
		projectile.set_direction(direction)  # Assuming your projectile has this method to set its direction


# Function to shoot projectiles repeatedly
func _shoot_projectile_repeatedly():
	while true:
		shoot_projectile()  # Spawn a bullet
		await get_tree().create_timer(spawn_rate).timeout  # Wait for the spawn_rate interval before shooting again
