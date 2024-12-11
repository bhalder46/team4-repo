extends CharacterBody2D

@onready var bug_death: AudioStreamPlayer = $"../BugDeath"

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite = $AnimatedSprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed: float = 100.0
var attack_cooldown: float = 1.5
var can_attack: bool = true
var facing_left: bool = true
@export var patrol_distance: float = 100.0
var initial_position: Vector2
var is_attacking: bool = false
var is_retreating: bool = false
var retreat_speed: float = 150.0
var player_in_chase_range: bool = false
var player_in_attack_range: bool = false

# New variables for retreat control
var retreat_start_position: Vector2
var retreat_distance: float = 70.0  # How far to retreat in pixels
var health: int = 2  # Number of hits required to trigger die

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
	
	if should_change_direction():
		change_direction()
	
	# Handle movement based on Area2D detection
	if player_in_attack_range and can_attack:
		perform_attack()
	elif player_in_chase_range:
		chase_player()
	else:
		patrol()
	
	move_and_slide()

func should_change_direction() -> bool:
	if $RayCast_left.is_colliding():
		var collider = $RayCast_left.get_collider()
		if collider and not collider.is_in_group("players"):
			return true
			
	if $RayCast_right.is_colliding():
		var collider = $RayCast_right.get_collider()
		if collider and not collider.is_in_group("players"):
			return true
	
	if facing_left and not $RayCast_down_left.is_colliding():
		return true
	elif not facing_left and not $RayCast_down_right.is_colliding():
		return true
		
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
	if not player:
		return
		
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * speed * 1.5  # Move faster when chasing
	animated_sprite.play("walk")
	
	# Update facing direction based on movement
	if velocity.x < 0 and not facing_left:
		change_direction()
	elif velocity.x > 0 and facing_left:
		change_direction()

func start_retreat():
	is_retreating = true
	retreat_start_position = global_position
	
func perform_retreat():
	print("retreating")
	if not player:
		is_retreating = false
		return
	
	# Calculate retreat direction
	var retreat_direction = -1 if player.global_position.x > global_position.x else 1
	velocity.x = retreat_speed * retreat_direction
	animated_sprite.play("walk")
	
	# Check if we've retreated far enough
	var distance_retreated = abs(global_position.x - retreat_start_position.x)
	if distance_retreated >= retreat_distance or should_change_direction():
		is_retreating = false
		can_attack = true  # Allow attacking again after retreat
	
func perform_attack():
	if not is_attacking and not is_retreating:
		is_attacking = true
		velocity.x = 0
		animated_sprite.play("attack")
		
		if player and player.has_method("take_damage"):
			player.take_damage(1) 
			
		can_attack = false
		
		# Wait for attack animation to finish
		await animated_sprite.animation_finished
		
		is_attacking = false
		start_retreat()  # Start retreat with position tracking
		
		# Start cooldown
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

# Area2D detection functions
func _on_chase_area_body_entered(body):
	if body.is_in_group("players"):
		player_in_chase_range = true

func _on_chase_area_body_exited(body):
	if body.is_in_group("players"):
		player_in_chase_range = false

func _on_attack_area_body_entered(body):
	if body.is_in_group("players"):
		player_in_attack_range = true

func _on_attack_area_body_exited(body):
	if body.is_in_group("players"):
		player_in_attack_range = false

func _on_area_entered(area):
	if area.is_in_group("bullets"):
		take_damage()

var is_dying = false 

func take_damage():
	
	animated_sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(.2).timeout
	animated_sprite.modulate = Color(1, 1, 1)
	health -= 1
	if health <= 0:
		var is_dying = true
		die()

func die():
	if is_dying:
		return
	is_attacking = false
	is_retreating = false
	if bug_death:
		bug_death.play()

	animated_sprite.play("death")
	set_physics_process(false)
	await animated_sprite.animation_finished
	queue_free()
