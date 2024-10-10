extends CharacterBody2D

signal health_updated(health)
signal killed()


const SPEED = 120.0
const JUMP_VELOCITY = -250.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var max_health = 3.0  # Define maximum health variable

@onready var animated_sprite = $AnimatedSprite2D
@export var bullet_scene: PackedScene
@onready var muzzle = $Gun/Muzzle
@onready var gun_shoot_sound = $"Gun/Shoot Sound"
@onready var gun_reload_sound = $"Gun/Reload Sound"
@onready var health = max_health 


var can_shoot = true
var shoot_cooldown = 0.4  # Time in seconds before the player can shoot again
var reload_time = 1.5  # Time in seconds to reload
var shoot_timer = 0.0  # Timer to track the shooting cooldown
var reload_timer = 0.0  # Timer to track the reload time
var shot_count = 0  # Count the number of shots fired
var max_shots = 6  # Maximum number of shots before needing to reload
var is_reloading = false  # Track if the gun is currently reloading

# Track the current side of the reticle (left or right)
var is_reticle_on_left = false

func _physics_process(delta: float) -> void:
	move_and_slide()
	update_gun_rotation()

	# Apply gravity if the player is not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get movement direction
	var direction := Input.get_axis("move_left", "move_right")

	# Play the appropriate animation based on movement state
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		if velocity.y < 0:
			animated_sprite.play("jump")
		elif velocity.y > 0:
			animated_sprite.play("fall")

	# Move left or right
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		# Smoothly stop when no input is provided
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Update shoot cooldown
	if not can_shoot:
		shoot_timer -= delta  # Decrease the cooldown timer
		if shoot_timer <= 0:
			can_shoot = true  # Reset shooting ability when cooldown is over

	# Update reload timer
	if is_reloading:
		reload_timer -= delta  # Decrease reload timer
		if reload_timer <= 0:
			is_reloading = false  # Reloading complete
			shot_count = 0  # Reset shot count
			$Gun.play("idle")  # Ensure the gun goes back to idle after reloading

	# Handle shooting
	if Input.is_action_just_pressed("shoot") and can_shoot and not is_reloading:
		shoot()

func shoot():
	
	$Gun.play("shoot")  

	if gun_shoot_sound:
		gun_shoot_sound.play()

	shot_count += 1  # Increment the shot count
	can_shoot = false
	shoot_timer = shoot_cooldown  # Reset the shoot cooldown timer

	var bullet = bullet_scene.instantiate()
	if bullet:
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = muzzle.global_position  # Set the bullet position to the muzzle's global position

		# Calculate direction to mouse
		var direction = (get_global_mouse_position() - muzzle.global_position).normalized()  # Calculate direction to target
		bullet.set_direction(direction)  # Pass the calculated direction to the bullet

		# Check if max shots reached
		if shot_count >= max_shots:
			start_reloading()  # Start reloading if max shots reached
			return  # Prevent firing a bullet if we are reloading
	else:
		print("Failed to instantiate bullet.")  # Debugging line

# Function to start reloading
func start_reloading():
	is_reloading = true  # Set the gun to reloading state
	reload_timer = reload_time  # Reset the reload timer

	# Wait for the shooting animation to finish before playing the reload animation
	await $Gun.animation_finished  
	
	if gun_reload_sound:
		gun_reload_sound.play()
		
	$Gun.play("reload")  

func update_gun_rotation():
	var mouse_position = get_global_mouse_position()
	var gun_direction = (mouse_position - $Gun.global_position).normalized()

	# Calculate the angle between the gun's position and the mouse
	var angle = gun_direction.angle()

	# Rotate the gun
	$Gun.rotation = angle

	# Introduce a clear threshold to decide when to flip (reticle on the left vs right)
	
	if mouse_position.x < global_position.x and not is_reticle_on_left:
		# Reticle crossed to the left side of the player
		is_reticle_on_left = true
		$Gun.flip_v = true
		$Gun.position.x = -10  # Move the gun 10 pixels left
		animated_sprite.flip_h = true  # Flip character sprite
		
	elif mouse_position.x > global_position.x and is_reticle_on_left:
		# Reticle crossed to the right side of the player
		is_reticle_on_left = false
		$Gun.flip_v = false
		$Gun.position.x = 10  # Move the gun 10 pixels right
		animated_sprite.flip_h = false  # Flip character sprite

	# Check if the gun is idle when not shooting or reloading
	if can_shoot and not is_reloading and !$Gun.is_playing():  # Play idle animation if gun is not currently shooting or reloading
		$Gun.play("idle")  

func damage(amount):
	_set_health(health - amount)

func kill():
	pass

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
			emit_signal("killed")
			
			
			
			
			
