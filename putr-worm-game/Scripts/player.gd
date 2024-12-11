extends CharacterBody2D

@export var SPEED = 135.0
@export var JUMP_VELOCITY = -320.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@export var bullet_scene: PackedScene
@onready var muzzle = $Gun/Muzzle
@onready var gun_shoot_sound = $"Gun/Shoot Sound"
@onready var gun_reload_sound = $"Gun/Reload Sound"
@onready var camera: Camera2D = $Camera2D
@onready var collision_shape = $CollisionShape2D

@onready var death_anim = $deathAnim
@onready var bugDetect = $Area2D

@onready var dubJump = $doubleJump

@onready var original_collision_shape_position = collision_shape.position
@onready var player_death: AudioStreamPlayer = $"../PlayerDeath"
@onready var player_hit: AudioStreamPlayer = $"../PlayerHit"
@onready var health_ui: Control = $"../Heart/HealthUI"

@export var double_jump_enabled: bool = false  # Toggle double jump
var jump_count: int = 0  # Track the number of jumps

@export var is_triple_shot: bool = false

var can_shoot = true
var shoot_cooldown = 0.4
var reload_time = 1.5
var shoot_timer = 0.0
var reload_timer = 0.0
var shot_count = 0
var max_shots = 6
var is_reloading = false

var is_reticle_on_left = false

var coyote_time: float = 0.2
var is_on_ground = false
var coyote_timer: float = 0.0

var disable_movement: bool = false
var disable_shooting: bool = false

var max_health: int = 3
var current_health: int = 3

var checkpoint_position: Vector2 = Vector2(0, 0)

signal health_changed(new_health)

@export var invincibility_duration: float = 1.0  # Total invincibility period
@export var flash_duration: float = 0.1  # Duration of the initial red flash
@export var blink_interval: float = 0.1  # Interval at which the character blinks during i-frames

var is_invincible: bool = false
var invincibility_timer: float = 0.0
var flash_timer: float = 0.0
var blink_timer: float = 1.0
var flashing: bool = false

var is_dead: bool = false

func _ready() -> void:
	animated_sprite.flip_h = true
	flip_collision_shape()
	
func _process(delta: float) -> void:
	# Handle the initial red flash
	if flashing:
		flash_timer -= delta
		if flash_timer <= 0:
			animated_sprite.modulate = Color(1, 1, 1)  # Reset to normal color
			flashing = false

	# Handle invincibility frames
	if is_invincible:
		invincibility_timer -= delta
		blink_timer -= delta

		# Toggle visibility at each blink interval
		if blink_timer <= 0:
			animated_sprite.visible = not animated_sprite.visible  # Toggle visibility
			blink_timer = blink_interval  # Reset blink timer

		# End invincibility when the timer runs out
		if invincibility_timer <= 0:
			is_invincible = false
			animated_sprite.visible = true  # Ensure the sprite is visible after i-frames end

func take_damage(amount: int) -> void:
	if is_invincible or is_dead:
		return  # Exit if invincible

	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	emit_signal("health_changed", current_health)
	
	CameraShakeGlobalSingleton.screenshake()  # Trigger screen shake
	if player_hit:
		player_hit.play()
	
	
	is_invincible = true
	invincibility_timer = invincibility_duration
	blink_timer = blink_interval  # Initialize blink timer for i-frames
	
	start_flashing()  # Trigger the red flash effect

	if current_health <= 0:
		die()

# Function to start the initial red flash effect
func start_flashing() -> void:
	animated_sprite.modulate = Color(1, 0, 0)  # Set to red
	flash_timer = flash_duration
	flashing = true

func die() -> void:
	
	if is_dead:
		print("Already dead, skipping die.")  # Debugging line
		return
	
	print("Entering die() function")  # Debugging line
	is_dead = true
	
	if player_death:
		player_death.play() #Play death sound effect
	
	print("Player has died!")
	
	# Check if the boss exists in the scene
	var boss = get_node_or_null("/root/Game/Boss_proto")
	if boss:
		print("boss healed")
		boss.heal()  # Call the heal method on the boss if it exists
		
	health_ui.on_player_death()
	
	respawn()


func respawn() -> void:
	
	is_invincible = true
	invincibility_timer = .5
	blink_timer = blink_interval  # Initialize blink timer for i-frames
	
	print("Respawning player...")  # Debugging line
	is_dead = false
	global_position = checkpoint_position  # Set player position to the checkpoint
	current_health = max_health  # Reset health to full
	emit_signal("health_changed", current_health)  # Update health UI
	print("Player respawned at checkpoint:", checkpoint_position)
	
# Function to Update Checkpoint Position
func update_checkpoint(new_checkpoint_position: Vector2) -> void:
	checkpoint_position = new_checkpoint_position
	print("Checkpoint updated to:", checkpoint_position)
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	update_gun_rotation()

	# Check if the player is on the ground
	is_on_ground = is_on_floor()

	# Apply gravity if the player is not on the floor
	if not is_on_ground:
		velocity.y += gravity * delta

	# Update coyote timer
	if not is_on_ground:
		coyote_timer -= delta  # Decrease coyote timer if in the air
	else:
		coyote_timer = coyote_time  # Reset coyote timer when touching the ground

	# Handle jumping, considering the disable_movement variable
	if Input.is_action_just_pressed("jump") and not disable_movement:
		if is_on_ground:
			# On ground, start the jump and reset the jump count
			velocity.y = JUMP_VELOCITY 
			jump_count = 1  # Reset jump count on the ground
		elif coyote_timer > 0:
			# If in the air but within the coyote time window, perform coyote jump
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0  # Reset coyote timer after using it for the jump
		elif double_jump_enabled and jump_count == 1:  # Second jump mid-air (after coyote jump or first jump)
			# Double jump after the first jump or coyote jump
			dubJump.play("doubleJump")
			velocity.y = JUMP_VELOCITY + 50  # Adjust for double jump height
			jump_count = 2  # Increment jump count after double jump
		
		elif double_jump_enabled and jump_count == 0:  # Second jump mid-air (after coyote jump or first jump)
			# Double jump after the first jump or coyote jump
			dubJump.play("doubleJump")
			velocity.y = JUMP_VELOCITY + 50  # Adjust for double jump height
			jump_count = 2  # Increment jump count after double jump

	
	# Get movement direction, considering the disable_movement variable
	var direction := Input.get_axis("move_left", "move_right")
	if disable_movement:
		direction = 0  # Disable left/right movement

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
			$Gun.play("idle")  # Ensudre the gun goes back to idle after reloading

	# Handle shooting, considering the disable_shooting variable
	if Input.is_action_pressed("shoot") and can_shoot and not is_reloading and not disable_shooting:
		shoot()

func shoot():
	$Gun.stop()
	$Gun.play("shoot")  

	if gun_shoot_sound:
		gun_shoot_sound.play()



	shot_count += 1  # Increment the shot count
	can_shoot = false
	shoot_timer = shoot_cooldown  # Reset the shoot cooldown timer

	var direction = (get_global_mouse_position() - muzzle.global_position).normalized()  # Calculate direction to target

	if is_triple_shot:
		# Bullet 1: Straight
		var projectile_straight = bullet_scene.instantiate()
		get_parent().add_child(projectile_straight)
		projectile_straight.global_position = muzzle.global_position
		projectile_straight.set_direction(direction)

		# Bullet 2: Slightly to the left
		var direction_left = direction.rotated(-0.04)  # Rotate left slightly
		var projectile_left = bullet_scene.instantiate()
		get_parent().add_child(projectile_left)
		projectile_left.global_position = muzzle.global_position
		projectile_left.set_direction(direction_left)

		# Bullet 3: Slightly to the right
		var direction_right = direction.rotated(0.04)  # Rotate right slightly
		var projectile_right = bullet_scene.instantiate()
		get_parent().add_child(projectile_right)
		projectile_right.global_position = muzzle.global_position
		projectile_right.set_direction(direction_right)

		# After shooting 3 times, set shot_count to 0 and start reloading
		if shot_count >= 3:
			start_reloading()  # Start reloading if max shots reached
			return  # Prevent further shooting until reload is complete

	else:
		# Regular shot
		var bullet = bullet_scene.instantiate()
		if bullet:
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = muzzle.global_position  # Set the bullet position to the muzzle's global position
			bullet.set_direction(direction)  # Pass the calculated direction to the bullet

	# Check if max shots reached (whether in triple shot or regular mode)
	if shot_count >= max_shots:
		start_reloading()  # Start reloading if max shots reached
		return  # Prevent firing a bullet if we are reloading
		
func _input(event):
	if event.is_action_pressed("reload") and not is_reloading:
		start_reloading()




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
		$Gun.position.x = -8  # Move the gun 10 pixels left
		animated_sprite.flip_h = false  # Flip character sprite
		flip_collision_shape()  # Flip collision shape
		
	elif mouse_position.x > global_position.x and is_reticle_on_left:
		# Reticle crossed to the right side of the player
		is_reticle_on_left = false
		$Gun.flip_v = false
		$Gun.position.x = 2  # Move the gun 10 pixels right
		animated_sprite.flip_h = true  # Flip character sprite
		flip_collision_shape()  # Flip collision shape

	# Check if the gun is idle when not shooting or reloading
	if can_shoot and not is_reloading and !$Gun.is_playing():
		$Gun.play("idle")
		
func flip_collision_shape() -> void:
	# Flip the scale on the x-axis based on the sprite's horizontal flip
	collision_shape.scale.x = 1.0 if animated_sprite.flip_h else -1.0
	
	# Move the collision shape -20 on the x-axis only when facing right
	if animated_sprite.flip_h:
		collision_shape.position.x = original_collision_shape_position.x - 3
	else:
		collision_shape.position.x = original_collision_shape_position.x
