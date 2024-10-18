extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
@onready var animated_sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed: float = 50.0       # Speed of mob along x-axis
var patrol_distance: float = 20.0  # How far the mob patrols left and right
var attack_range: float = 0.0  # Distance within which the bat can attack
var attack_cooldown: float = 1.5  # Cooldown time for attacks
var can_attack: bool = true
var facing_left: bool = false
var health: int = 1  # Health variable to track hits

var initial_position: Vector2
var amplitude: float = 40.0  # Amplitude for sinusoidal movement
var frequency: float = 2.0   # Frequency of the sinusoidal wave
var time_elapsed: float = 0.0  # Time counter for the sinusoidal movement

func _ready():
	initial_position = global_position
	if not player:
		print("Player not found")
	if position.x > player.position.x:
		$AnimatedSprite2D.flip_h = true
		facing_left = true

func _physics_process(delta):
	apply_gravity(delta)
	
	if player and is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)

		if distance_to_player < attack_range:
			attack_player()
		elif distance_to_player < attack_range * 2:
			chase_player()
		else:
			patrol(delta)

	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func patrol(delta):
	if abs(global_position.x - initial_position.x) >= patrol_distance:
		$AnimatedSprite2D.flip_h = !$AnimatedSprite2D.flip_h
		facing_left = !facing_left
	
	if facing_left:
		velocity.x = speed * -1
	else:
		velocity.x = speed * 1
		
	velocity.y = amplitude * frequency * cos(time_elapsed * frequency)  # Sinusoidal movement
	time_elapsed += delta  # Increment time for the sine wave
	animated_sprite.play("fly")

func chase_player():
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed * 1.5  # Move faster when chasing
	animated_sprite.play("fly")

func attack_player():
	if can_attack:
		velocity.x = 0  # Stop movement during attack
		animated_sprite.play("attack")
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _on_area_entered(area):
	if area.is_in_group("bullet"):
		health -= 1  # Decrease health when hit by a bullet
		if health <= 0:
			die()

func die():
	animated_sprite.play("death")
	set_physics_process(false)
	await animated_sprite.animation_finished
	queue_free()
