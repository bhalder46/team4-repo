extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite = $AnimatedSprite2D
@export var mob_projectile_scene: PackedScene
@export var speed: float = 100.0
@export var amplitude: float = 65.0
@export var frequency: float = 2.0
@export var attack_cooldown: float = 1.0
@export var patrol_distance: float = 300.0

var base_y: float
var time_elapsed: float = 0.0
var can_attack: bool = true
var facing_left: bool = false
var initial_position: Vector2
var player_in_range: bool = false

# New variables for hit effect, death, and fading
var is_dying: bool = false
var gravity: float = 980.0
var is_hurt: bool = false
var hurt_animation_time: float = 0.2
var fade_duration: float = 1.5  # Duration for the fade-in effect
var fade_time: float = 0.0      # Timer to track fading progress
var is_fading_in: bool = true   # Flag to check if fading is in progress
var is_ready_to_attack: bool = false  # Flag to check if it's ready to shoot

# New variable to track when to start fade out
var fade_out_timer: float = 6.0  # Time before starting fade-out

func _ready():
	base_y = position.y
	initial_position = global_position
	if not player:
		print("Player not found")
	if position.x > player.position.x:
		animated_sprite.flip_h = true
		facing_left = true
	# Make sure death raycast starts disabled
	$DeathRaycast.enabled = false
	
	# Start fade-in process
	fade_time = 0.0
	is_fading_in = true
	animated_sprite.modulate.a = 0.0  # Start fully transparent
	# Optionally, delay patrol start until fade-in is complete
	await fade_in()

	# Start fade-out after 8 seconds
	await get_tree().create_timer(fade_out_timer).timeout
	can_attack = false
	fade_out()

func _physics_process(delta):
	if is_fading_in:
		# Update fade-in progress
		fade_time += delta
		animated_sprite.modulate.a = lerp(0.0, 1.0, fade_time / fade_duration)  # Linearly interpolate alpha
		if fade_time >= fade_duration:
			is_fading_in = false  # Stop fading once the duration is reached
			is_ready_to_attack = true  # Allow shooting after fade-in is complete
	
	if is_dying:
		# Apply gravity while dying
		velocity.y += gravity * delta
		move_and_slide()
		
		# Check if the death raycast hit something
		if $DeathRaycast.is_colliding():
			await get_tree().create_timer(0.5).timeout
			queue_free()
		return
		
	time_elapsed += delta
	handle_collisions()
	
	if player_in_range and can_attack and is_ready_to_attack and is_instance_valid(player):
		shoot_at_player()
	else:
		patrol(delta)
	
	move_and_slide()

func handle_collisions():
	if $RayCast_left.is_colliding() and not $RayCast_left.get_collider().is_in_group("players"):
		flip_direction()
	
	if $RayCast_right.is_colliding() and not $RayCast_right.get_collider().is_in_group("players"):
		flip_direction()

func flip_direction():
	facing_left = !facing_left
	animated_sprite.flip_h = !animated_sprite.flip_h
	velocity.x *= -1

func patrol(delta):
	if abs(global_position.x - initial_position.x) >= patrol_distance:
		flip_direction()
	
	if facing_left:
		velocity.x = speed * -1
	else:
		velocity.x = speed * 1
	
	# Sinusoidal vertical movement
	velocity.y = amplitude * frequency * cos(time_elapsed * frequency)
	
	animated_sprite.play("fly")

func shoot_at_player():
	if can_attack and player:
		animated_sprite.play("attack")
		can_attack = false
		
		var projectile = mob_projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position
		
		var direction = (player.global_position - global_position).normalized()
		projectile.set_direction(direction)
		
		# Update facing direction based on player position
		if player.global_position.x < global_position.x and not facing_left:
			flip_direction()
		elif player.global_position.x > global_position.x and facing_left:
			flip_direction()
		
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func take_damage():
	if is_dying:
		return
		
	# Visual feedback - red flash
	animated_sprite.modulate = Color(1, 0.3, 0.3)  # Red tint
	await get_tree().create_timer(hurt_animation_time).timeout
	animated_sprite.modulate = Color(1, 1, 1)  # Reset tint
	
	die()

func _on_detection_area_body_entered(body):
	if body.is_in_group("players"):
		player_in_range = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("players"):
		player_in_range = false

func _on_area_entered(area):
	if area.is_in_group("bullets"):
		take_damage()

func die():
	is_dying = true
	animated_sprite.play("death")
	
	# Enable the death raycast when starting to die
	$DeathRaycast.enabled = true
	
	# Add some initial downward velocity and slight horizontal velocity
	velocity.y = -100  # Small upward force
	velocity.x = velocity.x * 0.5  # Maintain some momentum
	
	# Set a backup timer just in case
	await get_tree().create_timer(1.5).timeout
	queue_free()

# Function to handle fade-in
func fade_in():
	await get_tree().create_timer(fade_duration).timeout
	# Fade-in process completes after fade_duration

# Function to handle fade-out
func fade_out():
	can_attack = false
	# Fade out logic
	fade_time = 0.0
	var fade_out_duration: float = 0.8  # Duration for the fade-out effect

	while fade_time < fade_out_duration:
		fade_time += get_process_delta_time()
		animated_sprite.modulate.a = lerp(1.0, 0.0, fade_time / fade_out_duration)
		await get_tree().create_timer(get_process_delta_time()).timeout
	
	# After fade-out is complete, queue the mob for removal
	queue_free()
