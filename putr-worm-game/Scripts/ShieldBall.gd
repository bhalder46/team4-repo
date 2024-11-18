extends RigidBody2D

@export var max_bounces: int = 12
var bounce_count: int = 0
const Player = preload("res://Scripts/player.gd")
@export var move_left: bool = false  # Toggle for initial movement direction (true = left, false = right)

@onready var shield_sprite: AnimatedSprite2D = $Shield  # Reference to the shield AnimatedSprite2D
@onready var bug_sprite: AnimatedSprite2D = $Bug        # Reference to the bug AnimatedSprite2D

# Function to handle the ball's collision and bounces
func _on_body_entered(body: Node2D) -> void:
	bounce_count += 1
	print("Bounce Count: ", bounce_count, "/", max_bounces)
	
	if body is Player:  # Replace 'Player' with the correct script or node name
		body.take_damage(1)  # Pass the damage amount as needed
		print("Player hit! Damage applied.")
	
	# Check if the ball has hit the max number of bounces
	if bounce_count >= max_bounces:
		print("Max bounces reached. Playing die animation.")
		# Remove the ball from the scene
		queue_free()

	if bounce_count == max_bounces - 1:
		shield_sprite.play("die")

# Timer simulation using await (Godot 4.x)
func _ready():
	# Set rigidbody gravity scale to 0 initially
	gravity_scale = 0
	bug_sprite.modulate = Color(1, 1, 1, 0)  # Fully transparent

	# Create a tween for the fade-in effect
	var tween = create_tween()
	tween.tween_property(bug_sprite, "modulate", Color(1, 1, 1, 1), 1.0)  # Fade to fully opaque over 1 second
	
	shield_sprite.play("spawn")

	# Await for 1.5 seconds before modifying gravity scale
	await get_tree().create_timer(1.2).timeout  # Use create_timer to await the timeout

	gravity_scale = 0.856  # Set the gravity scale to the desired value after the delay

	# Set initial direction based on the Inspector toggle
	if move_left:
		linear_velocity = Vector2(-150, 0)  # Move left
	else:
		linear_velocity = Vector2(150, 0)  # Move right

	shield_sprite.play("idle")

# Make the Bug spin as it bounces
func _physics_process(delta: float) -> void:
	# Adjust the rotation speed to control the spin rate of the bug
	bug_sprite.rotation += 3 * delta  # Rotate the bug sprite
