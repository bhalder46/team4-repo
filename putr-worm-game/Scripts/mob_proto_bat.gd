extends CharacterBody2D

@onready var player= get_parent().get_node("Dummy")


var base_y: float
var speed: float = 250.0       # Speed of mob along x-axis
var amplitude: float = 65.0    # How far the mob moves up/down in its motion (amplitude)
var frequency: float = 2.0     # Frequency of the wave (how fast it oscillates)
var time_elapsed: float = 0.0  # Keeping track of time to calculate the sine wave

var attack_range: float = 150.0
var attack_cooldown: float = 1.5
var can_attack: bool = true
var facing_left: bool = false

func _ready():
	base_y = position.y
	if not player:
		print("Player not found")
	if position.x > player.position.x:
		$AnimatedSprite2D.flip_h = true
		facing_left = true
	

func _physics_process(delta):
	
	time_elapsed += delta  # Incrementing the time every frame
	
	if player and is_instance_valid(player):
		var distance_x = position.x - player.position.x
		
		if abs(distance_x) < attack_range:
			move_towards_player(delta)
			
			if can_attack and abs(distance_x) < 20.0:
				attack_player()
		else:
			move_sinusoidal(delta)
	
	move_and_slide()
	
func move_sinusoidal(delta):
	if facing_left:
		velocity.x = speed * -1
	else:
		velocity.x = speed *1
	velocity.y = amplitude*frequency*cos(time_elapsed*frequency)
	
	# Moving forward on the x-axis
	#var movement_x = speed * delta
	# Calculating movement on the y-axis using a sin function.
	#var movement_y = amplitude * sin(time_elapsed * frequency)
	# Applying the movement
	$AnimatedSprite2D.play("fly")
	#position.x += movement_x
	#position.y = base_y + movement_y
	
func move_towards_player(delta):
	
	var direction = (player.position - position).normalized()
	direction += Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
	direction = direction.normalized()
	#position += direction * speed * delta
	velocity = direction*speed
	
func attack_player():
	if can_attack:
		$AnimatedSprite2D.play("attack")
		#print("Attacking player")
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
		
		
func _on_area_entered(area):
	if area.is_in_group("bullets"):
		die()
	
func die():
	$AnimatedSprite2D.play("death")
	await $AnimatedSprite2D.animation_finished
	queue_free()
	
