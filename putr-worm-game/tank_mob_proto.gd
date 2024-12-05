extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var bug_death: AudioStreamPlayer = $"../BugDeath"


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed: float = 60.0
var attack_cooldown: float = .5
var can_attack: bool = true
var facing_left: bool = false
@export var patrol_distance: float = 300.0
var initial_position: Vector2

@onready var is_dying: bool = false

# States
var is_chasing: bool = false
var is_attacking: bool = false
var is_hurt: bool = false

# Health system
var max_health: float = 100.0
var current_health: float = max_health
var damage_taken_per_hit: float = 20.0
var hurt_animation_time: float = 0.2
var knockback_force: float = 150.0
var is_heavy: bool = true
var player_in_attack_area: bool = false  # Track if player is in attack area

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
	
	if is_chasing:
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
	velocity.x = direction.x * speed * 1.7  # Only slightly faster when chasing
	animated_sprite.play("walk")
	
	if velocity.x < 0 and not facing_left:
		change_direction()
	elif velocity.x > 0 and facing_left:
		change_direction()

func attack_player():
	if is_dying:
		return
		
	if not is_attacking and can_attack and player_in_attack_area:
		is_attacking = true
		velocity.x = 0
		animated_sprite.play("attack")
		
		if player and player.has_method("take_damage"):
			player.take_damage(1)  # Call the player's take_damage method
			
		can_attack = false
	
		await animated_sprite.animation_finished
		is_attacking = false
	
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
		
		# If the player is still in the area, trigger another attack
		if player_in_attack_area:
			attack_player()

# Functions for Area2D detection
func _on_chase_area_body_entered(body):
	if body.is_in_group("players"):
		is_chasing = true

func _on_chase_area_body_exited(body):
	if body.is_in_group("players"):
		is_chasing = false

func _on_attack_area_body_entered(body):
	if body.is_in_group("players"):
		player_in_attack_area = true
		if can_attack:
			attack_player()

func _on_attack_area_body_exited(body):
	if body.is_in_group("players"):
		player_in_attack_area = false
		can_attack = false

func take_damage(amount: float, knockback_direction: Vector2 = Vector2.ZERO):

		
	current_health -= amount
	health_bar.value = current_health
	
	# Apply knockback
	if knockback_direction != Vector2.ZERO:
		var actual_knockback = knockback_force * (0.5 if is_heavy else 1.0)
		velocity = knockback_direction.normalized() * actual_knockback
	
	# Visual feedback
	is_hurt = true
	animated_sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(hurt_animation_time).timeout
	animated_sprite.modulate = Color(1, 1, 1)
	is_hurt = false
	
	if current_health <= 0:
		die()

func _on_area_entered(area):
	if area.is_in_group("bullets"):
		var bullet_position = area.global_position
		var knockback_direction = global_position - bullet_position
		take_damage(damage_taken_per_hit, knockback_direction)
		print("area entered")

func die():
	is_dying = true
	if bug_death:
		bug_death.play()
	is_attacking = false
	animated_sprite.play("death")
	set_physics_process(false)
	health_bar.hide()
	await animated_sprite.animation_finished
	queue_free()
