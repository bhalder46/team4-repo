extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -250.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@export var bullet_scene: PackedScene
@onready var muzzle = $Gun/Muzzle
var can_shoot = true

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
		# Check if player is jumping or falling
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

	# Handle shooting
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	can_shoot = false
	
	var bullet = bullet_scene.instantiate()
	if bullet:
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = muzzle.global_position  # Set the bullet position to the muzzle's global position
		
		# Calculate direction to mouse
		var direction = (get_global_mouse_position() - muzzle.global_position).normalized()  # Calculate direction to target
		bullet.set_direction(direction)  # Pass the calculated direction to the bullet
	else:
		print("Failed to instantiate bullet.")  # Debugging line

	# Delay for cooldown before shooting again
	await get_tree().create_timer(0.1).timeout
	can_shoot = true

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



	
