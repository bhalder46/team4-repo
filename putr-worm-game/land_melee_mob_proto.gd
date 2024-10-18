extends CharacterBody2D


@onready var player = get_parent().get_node("Dummy")
@onready var animated_sprite = $AnimatedSprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var speed: float = 100.0       # Speed of mob along x-axis
var attack_range: float = 50.0
var attack_cooldown: float = 1.5
var can_attack: bool = true
var facing_left: bool = false

var patrol_distance: float = 100.0
var initial_position: Vector2

func _ready():
	if not player:
		print("Player not found")
	initial_position = global_position
	if position.x > player.position.x:
		$AnimatedSprite2D.flip_h = true
		facing_left = true

func _physics_process(delta):
	apply_gravity(delta)
	
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player < attack_range:
			attack_player()
		elif distance_to_player < attack_range*2:
			chase_player()
		else:
			patrol()

	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func patrol():
	if abs(global_position.x - initial_position.x) >= patrol_distance:
		$AnimatedSprite2D.flip_h = !$AnimatedSprite2D.flip_h
		facing_left = !facing_left
		
	if facing_left:
		velocity.x = speed * -1
	else:
		velocity.x = speed * 1
		
	animated_sprite.play("walk")

func chase_player():
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed * 1.5  # Move faster when chasing
	animated_sprite.play("walk")

func attack_player():
	velocity.x = 0
	animated_sprite.play("attack")
	can_attack = false
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
