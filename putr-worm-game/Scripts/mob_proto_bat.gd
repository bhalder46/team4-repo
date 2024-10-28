extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
var base_y: float
var speed: float = 150.0
var amplitude: float = 65.0
var frequency: float = 2.0
var time_elapsed: float = 0.0
var attack_range: float = 150.0
var attack_cooldown: float = 1.5
var can_attack: bool = true
var facing_left: bool = false


var patrol_distance: float = 300.0
var initial_position: Vector2
var retreat_distance: float = 150.0
var is_retreating: bool = false
var is_attacking: bool = false
var attack_height_offset: float = -20.0

func _ready():
	base_y = position.y
	initial_position = global_position
	if not player:
		print("Player not found")
	if position.x > player.position.x:
		$AnimatedSprite2D.flip_h = true
		facing_left = true

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return
		
	time_elapsed += delta
	
	# Handle wall collisions
	if $RayCast_left.is_colliding() and not $RayCast_left.get_collider().is_in_group("players"):
		change_direction()
	if $RayCast_right.is_colliding() and not $RayCast_right.get_collider().is_in_group("players"):
		change_direction()
	
	# Get player's position with height offset for targeting
	var target_position = player.global_position + Vector2(0, attack_height_offset)
	# Calculate horizontal distance only
	var distance_to_player = abs(global_position.x - player.global_position.x)
	
	# Don't process movement during attack animation
	if is_attacking:
		return
	
	if is_retreating:
		retreat(delta)
		# Use horizontal distance for retreat check
		if abs(global_position.x - player.global_position.x) > retreat_distance:
			is_retreating = false
			can_attack = true
	# If in attack range and can attack (using horizontal distance)
	elif distance_to_player < attack_range and can_attack:
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
		
		if distance_to_player < 30.0:
			perform_attack()
	# If close to player but can't attack yet, maintain some distance
	elif distance_to_player < attack_range and not can_attack:
		var direction = (global_position - target_position).normalized()
		velocity = direction * speed
	# Otherwise patrol
	else:
		patrol(delta)
	
	# Update sprite direction
	if velocity.x < 0 and not facing_left:
		change_direction()
	elif velocity.x > 0 and facing_left:
		change_direction()
	
	move_and_slide()

func change_direction():
	facing_left = !facing_left
	$AnimatedSprite2D.flip_h = !$AnimatedSprite2D.flip_h
	
func patrol(delta):
	var distance_from_start = global_position.x - initial_position.x
	if abs(distance_from_start) >= patrol_distance:
		change_direction()
	
	if facing_left:
		velocity.x = speed * -1
	else:
		velocity.x = speed * 1
	
	velocity.y = amplitude * frequency * cos(time_elapsed * frequency)
	$AnimatedSprite2D.play("fly")

func retreat(delta):
	# Use offset position for movement but consider horizontal distance for logic
	var target_position = player.global_position + Vector2(0, attack_height_offset)
	var retreat_direction = (global_position - target_position).normalized()
	velocity = retreat_direction * speed * 1.5
	$AnimatedSprite2D.play("fly")

func perform_attack():
	if can_attack and not is_attacking:
		is_attacking = true
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("attack")
		can_attack = false
		
		await $AnimatedSprite2D.animation_finished
		
		is_attacking = false
		is_retreating = true
		
		await get_tree().create_timer(attack_cooldown).timeout

func _on_area_entered(area):
	if area.is_in_group("bullets"):
		die()

func die():
	$AnimatedSprite2D.play("death")
	set_physics_process(false)
	await $AnimatedSprite2D.animation_finished
	queue_free()
