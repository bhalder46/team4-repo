extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed: float = 60.0        # Slower than other mobs
var attack_range: float = 70.0 # Slightly larger attack range
var attack_cooldown: float = 2.0  # Longer attack cooldown
var can_attack: bool = true
var facing_left: bool = false
var patrol_distance: float = 300.0
var initial_position: Vector2

# Health system
var max_health: float = 100.0
var current_health: float = max_health
var damage_taken_per_hit: float = 20.0  # 5 hits to kill
var is_hurt: bool = false
var hurt_animation_time: float = 0.2
var knockback_force: float = 100.0
var is_heavy: bool = true  # Reduces knockback
var is_attacking: bool = false 

func _ready():
	if not player:
		print("Player not found")
	initial_position = global_position
	if position.x > player.position.x:
		$AnimatedSprite2D.flip_h = true
		facing_left = true
	setup_health_bar()

func setup_health_bar():
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_bar.show()

func _physics_process(delta):
	if is_hurt or is_attacking:
		move_and_slide()
		return
		
	apply_gravity(delta)
	
	if should_change_direction():
		change_direction()
	
	if player:
		var distance_to_player = abs(global_position.x - player.global_position.x)
		
		if distance_to_player < attack_range and can_attack:
			attack_player()
		elif distance_to_player < attack_range * 2:
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
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed * 1.2  # Only slightly faster when chasing
	animated_sprite.play("walk")
	
	if velocity.x < 0 and not facing_left:
		change_direction()
	elif velocity.x > 0 and facing_left:
		change_direction()

func attack_player():
	if not is_attacking and can_attack:
		is_attacking = true
		velocity.x = 0
		animated_sprite.play("attack")
		can_attack = false
	
	await animated_sprite.animation_finished
	is_attacking = false
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_damage(amount: float, knockback_direction: Vector2 = Vector2.ZERO):
	if is_hurt:
		return
		
	current_health -= amount
	health_bar.value = current_health
	
	# Apply knockback
	if knockback_direction != Vector2.ZERO:
		var actual_knockback = knockback_force * (0.5 if is_heavy else 1.0)
		velocity = knockback_direction.normalized() * actual_knockback
	
	# Visual feedback
	is_hurt = true
	animated_sprite.modulate = Color(1, 0.3, 0.3)  # Red tint
	await get_tree().create_timer(hurt_animation_time).timeout
	animated_sprite.modulate = Color(1, 1, 1)  # Reset tint
	is_hurt = false
	
	# Check if dead
	if current_health <= 0:
		die()

func _on_area_entered(area):
	if area.is_in_group("bullets"):
		var bullet_position = area.global_position
		var knockback_direction = global_position - bullet_position
		take_damage(damage_taken_per_hit, knockback_direction)

func die():
	animated_sprite.play("death")
	set_physics_process(false)
	health_bar.hide()
	await animated_sprite.animation_finished
	queue_free()
