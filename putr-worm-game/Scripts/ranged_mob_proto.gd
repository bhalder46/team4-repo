extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite = $AnimatedSprite2D
@export var mob_projectile_scene: PackedScene

var base_y: float
var speed: float = 100.0
var amplitude: float = 65.0
var frequency: float = 2.0
var time_elapsed: float = 0.0
var attack_range: float = 400.0
var attack_cooldown: float = 1.0
var can_attack: bool = true
var facing_left: bool = false
var patrol_distance: float = 300.0
var initial_position: Vector2

func _ready():
	base_y = position.y
	initial_position = global_position
	if not player:
		print("Player not found")
	if position.x > player.position.x:
		animated_sprite.flip_h = true
		facing_left = true

func _physics_process(delta):
	time_elapsed += delta

	handle_collisions()
	
	if player and is_instance_valid(player):
		var distance = position.distance_to(player.position)
		
		if distance < attack_range and can_attack:
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
	if can_attack:
		animated_sprite.play("attack")
		can_attack = false
		
		var projectile = mob_projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position
		
		var direction = (player.global_position - global_position).normalized()
		projectile.set_direction(direction)
		
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _on_area_entered(area):
	if area.is_in_group("bullets"):
		die()

func die():
	animated_sprite.play("death")
	set_physics_process(false)
	await animated_sprite.animation_finished
	queue_free()
