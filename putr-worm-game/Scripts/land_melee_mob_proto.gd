extends CharacterBody2D

@onready var player: CharacterBody2D = get_parent().get_node("Player")
@onready var animated_sprite = $AnimatedSprite2D

const PlayerScript = preload("res://Scripts/player.gd")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed: float = 100.0
var attack_range: float = 30.0
var attack_cooldown: float = 1.5
var can_attack: bool = true
var facing_left: bool = true
var patrol_distance: float = 100.0
var initial_position: Vector2
var is_attacking: bool = false
var is_retreating: bool = false
var retreat_distance: float = 100.0  # How far to retreat
var retreat_speed: float = 150.0     # Speed during retreat

func _ready():
	if not player:
		print("Player not found")
	initial_position = global_position
	if position.x < player.position.x:
		$AnimatedSprite2D.flip_h = true
		facing_left = false

func _physics_process(delta):
	apply_gravity(delta)
	
	# Skip movement and direction changes if attacking
	if is_attacking:
		move_and_slide()
		return
	
	# Handle retreat movement
	if is_retreating:
		perform_retreat()
		move_and_slide()
		return
	
	# First check if we should change direction due to wall or ledge
	if should_change_direction():
		change_direction()
	
	if player:
		var distance_to_player = abs(global_position.x - player.global_position.x)
		
		if distance_to_player < attack_range and can_attack:
			perform_attack()
		elif distance_to_player < attack_range * 2:
			chase_player()
		else:
			patrol()
	
	move_and_slide()

func should_change_direction() -> bool:
	# Check wall collisions
	if $RayCast_left.is_colliding():
		var collider = $RayCast_left.get_collider()
		if collider and not collider.is_in_group("players"):
			return true
			
	if $RayCast_right.is_colliding():
		var collider = $RayCast_right.get_collider()
		if collider and not collider.is_in_group("players"):
			return true
	
	# Check ledge detection, excluding player collisions
	if facing_left and not $RayCast_down_left.is_colliding():
		return true
	elif not facing_left and not $RayCast_down_right.is_colliding():
		return true
		
	# Check if the down raycast is hitting a player (ignore it if it is)
	if $RayCast_down_left.is_colliding():
		var collider = $RayCast_down_left.get_collider()
		if collider and collider.is_in_group("players"):
			return false
			
	if $RayCast_down_right.is_colliding():
		var collider = $RayCast_down_right.get_collider()
		if collider and collider.is_in_group("players"):
			return false
	
	return false

func change_direction():
	facing_left = !facing_left
	$AnimatedSprite2D.flip_h = !$AnimatedSprite2D.flip_h
	velocity.x = speed * (-1 if facing_left else 1)

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func patrol():
	if abs(global_position.x - initial_position.x) >= patrol_distance:
		change_direction()
	
	if facing_left:
		velocity.x = speed * -1
	else:
		velocity.x = speed * 1
		
	animated_sprite.play("walk")

func chase_player():
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed * 1.5  # Move faster when chasing
	animated_sprite.play("walk")
	
	# Update facing direction based on movement
	if velocity.x < 0 and not facing_left:
		change_direction()
	elif velocity.x > 0 and facing_left:
		change_direction()

func perform_retreat():
	# Check if we've retreated far enough
	var distance_retreated = abs(global_position.x - player.global_position.x)
	if distance_retreated >= retreat_distance:
		is_retreating = false
		return
		
	# Move away from player
	var retreat_direction = -1 if player.global_position.x > global_position.x else 1
	velocity.x = retreat_speed * retreat_direction
	animated_sprite.play("walk")
	
	# Check for obstacles during retreat
	if should_change_direction():
		is_retreating = false

func perform_attack():
	if not is_attacking and not is_retreating:
		is_attacking = true
		velocity.x = 0
		print("Attack started")
		animated_sprite.play("attack")
		can_attack = false
		
		# Wait for attack animation to finish
		await animated_sprite.animation_finished
		
		is_attacking = false
		is_retreating = true  # Start retreat after attack
		
		# Start cooldown
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true


func _on_area_entered(body):
	if body.is_in_group("players"):  # Ensure it's the player
		print("collision detected with player")
		var player = body as PlayerScript
		if player and not player.is_invincible:
			print("player is not invincible, applying damage")
			player.take_damage(1)
		else:
			print("player is invincible, no damage applied")
	elif body.is_in_group("bullets"):  
		die()

func die():
	# Stop any ongoing attack or retreat
	is_attacking = false
	is_retreating = false
	animated_sprite.play("death")
	set_physics_process(false)
	await animated_sprite.animation_finished
	queue_free()
