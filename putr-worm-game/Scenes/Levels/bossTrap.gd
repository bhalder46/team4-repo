extends Sprite2D

@export var bullet_scene: PackedScene  # Drag the bullet scene into this export variable.
@export var bullet_speed = 200  # Adjust the speed as needed.
@export var spawn_interval = 1.0  # Time in seconds between each bullet spawn.

@onready var left_marker = $Left
@onready var right_marker = $Right
@onready var up_marker = $Up
@onready var down_marker = $Down
@onready var redLight = $RedLight

var spawn_alternate = true  # Track whether to spawn left-right or up-down

func _ready():
	# Fade in red light, start spawning bullets, then fade out and queue free
	await fade_in()
	spawn_bullet_loop()
	await fade_out_and_free()

func fade_in() -> void:
	modulate.a = 0  # Start with full transparency
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 1)  # Fade in over 1.5 seconds
	await tween.finished  # Wait for fade-in to complete

	# Gradually increase red light intensity from 0 to 2 over 2 seconds
	await gradually_increase_intensity(2, 2)
	
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
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1)  # Fade out the sprite
	await gradually_decrease_intensity(0, 1)  # Fade out the light

	await tween.finished  # Wait for the sprite fade-out to complete

	queue_free()  # Free the object


func spawn_bullet_at_marker(marker: Node2D, direction: Vector2):
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.position = marker.position
	bullet_instance.set_direction(direction)  # Assumes bullet script has set_direction method
	bullet_instance.speed = bullet_speed  # Set the bullet's speed if required
	add_child(bullet_instance)

# Gradually increases the intensity from 0 to target over a given time
func gradually_increase_intensity(target, duration):
	var start_value = 0
	var elapsed_time = 0.0
	
	# Ensure RedLight's material is of type ShaderMaterial before accessing
	if redLight.material and redLight.material is ShaderMaterial:
		redLight.material.set_shader_parameter("intensity", start_value)

	# Gradually increase the intensity
	while elapsed_time < duration:
		# Lerp the intensity value
		var current_value = lerp(start_value, target, elapsed_time / duration)
		# Update the shader parameter
		if redLight.material and redLight.material is ShaderMaterial:
			redLight.material.set_shader_parameter("intensity", current_value)
		# Wait for the next frame
		await get_tree().create_timer(0.01).timeout
		elapsed_time += 0.01
	
	# Ensure we set the final value exactly to the target
	if redLight.material and redLight.material is ShaderMaterial:
		redLight.material.set_shader_parameter("intensity", target)
		print("Final intensity set to ", target)

# Gradually decreases the intensity from the current value to target over a given time
func gradually_decrease_intensity(target, duration):
	var start_value = 2  # Assuming the initial intensity is set to 2 during fade-in
	var elapsed_time = 0.0
	
	# Ensure RedLight's material is of type ShaderMaterial before accessing
	if redLight.material and redLight.material is ShaderMaterial:
		redLight.material.set_shader_parameter("intensity", start_value)

	# Gradually decrease the intensity
	while elapsed_time < duration:
		# Lerp the intensity value
		var current_value = lerp(start_value, target, elapsed_time / duration)
		# Update the shader parameter
		if redLight.material and redLight.material is ShaderMaterial:
			redLight.material.set_shader_parameter("intensity", current_value)
		# Wait for the next frame
		await get_tree().create_timer(0.01).timeout
		elapsed_time += 0.01
	
	# Ensure we set the final value exactly to the target
	if redLight.material and redLight.material is ShaderMaterial:
		redLight.material.set_shader_parameter("intensity", target)
		print("Final intensity set to ", target)
