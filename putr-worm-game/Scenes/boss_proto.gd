extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $BossHealthBar

@export var mob_projectile_scene: PackedScene
@export var attack_cooldown: float = 1.0

var can_attack: bool = true
var player_in_range: bool = false

# Health system
var max_health: float = 1000.0
var current_health: float = max_health
var damage_taken_per_hit: float = 20.0
var is_hurt: bool = false
var hurt_animation_time: float = 0.2
var is_dying: bool = false

func _ready():
	if not player:
		print("Player not found")
	setup_health_bar()

func setup_health_bar():
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_bar.show()

func _physics_process(_delta):
	if is_dying:
		return
		
	if player_in_range and can_attack and is_instance_valid(player):
		shoot_at_player()

func shoot_at_player():
	if can_attack and player:
		animated_sprite.play("attack")
		can_attack = false
		
		var projectile = mob_projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position
		
		var direction = (player.global_position - global_position).normalized()
		projectile.set_direction(direction)
		
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func take_damage():
	if is_dying:
		return
		
	current_health -= damage_taken_per_hit
	health_bar.value = current_health
	
	# Visual feedback - red flash
	animated_sprite.modulate = Color(1, 0.3, 0.3)  # Red tint
	await get_tree().create_timer(hurt_animation_time).timeout
	animated_sprite.modulate = Color(1, 1, 1)  # Reset tint
	
	if current_health <= 0:
		die()

func _on_detection_area_body_entered(body):
	if body.is_in_group("players"):
		player_in_range = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("players"):
		player_in_range = false

func _on_area_entered(area):
	if area.is_in_group("bullets"):
		take_damage()

func die():
	is_dying = true
	animated_sprite.play("death")
	health_bar.hide()
	
	# Wait for death animation
	await animated_sprite.animation_finished
	queue_free()
