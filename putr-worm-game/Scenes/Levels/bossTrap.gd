extends Sprite2D

@export var bullet_scene: PackedScene  # Drag the bullet scene into this export variable.
@export var bullet_speed = 200  # Adjust the speed as needed.
@export var spawn_interval = 1.0  # Time in seconds between each bullet spawn.

@onready var left_marker = $Left
@onready var right_marker = $Right
@onready var up_marker = $Up
@onready var down_marker = $Down
@onready var red_light = $RedLight  # Assuming the RedLight is a PointLight2D node

var spawn_alternate = true  # Track whether to spawn left-right or up-down

func _ready():
	# Fade in, start spawning bullets, then fade out and queue free
	await fade_in()
	await animate_light_energy()  # Animate the RedLight energy to 30
	spawn_bullet_loop()
	await fade_out_and_free()

func fade_in() -> void:
	modulate.a = 0  # Start with full transparency
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 1)  # Fade in over 1 second
	await tween.finished  # Wait for fade-in to complete

func animate_light_energy() -> void:
	# Animate the RedLight's energy from 0 to 30 over 1 second
	var tween = create_tween()
	tween.tween_property(red_light, "energy", 40, 1)  # 1 second transition to full energy
	await tween.finished  # Wait for animation to complete

var is_spawning = true  # Track whether spawning is active

func spawn_bullet_loop() -> void:
	while is_spawning:  # Check this flag to control the loop
		if spawn_alternate:
			spawn_bullet_at_marker(left_marker, Vector2.RIGHT)
			spawn_bullet_at_marker(right_marker, Vector2.LEFT)
		else:
			spawn_bullet_at_marker(up_marker, Vector2.UP)
			spawn_bullet_at_marker(down_marker, Vector2.DOWN)

		spawn_alternate = !spawn_alternate
		await get_tree().create_timer(spawn_interval).timeout

func fade_out_and_free() -> void:
	await get_tree().create_timer(10).timeout

	is_spawning = false  # Stop spawning bullets
	# Animate the light's energy from 30 to 0 over 1 second before fading out the sprite
	await animate_light_fade_out()
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1)  # Fade out the sprite
	await tween.finished  # Wait for the sprite fade-out to complete

	queue_free()  # Free the object

# New function to animate the RedLight's energy fade-out
func animate_light_fade_out() -> void:
	# Animate the RedLight's energy from 30 to 0 over 1 second
	var tween = create_tween()
	tween.tween_property(red_light, "energy", 0, 0.5)  # 1 second transition to 0 energy
	await tween.finished  # Wait for animation to complete

func spawn_bullet_at_marker(marker: Node2D, direction: Vector2):
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.position = marker.position
	bullet_instance.set_direction(direction)  # Assumes bullet script has set_direction method
	bullet_instance.speed = bullet_speed  # Set the bullet's speed if required
	add_child(bullet_instance)
