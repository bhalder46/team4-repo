extends RigidBody2D

@export var max_bounces: int = 12
var bounce_count: int = 0
@onready var shield_sprite: AnimatedSprite2D = $Shield  # Reference to the shield AnimatedSprite2D
@onready var bug_sprite: AnimatedSprite2D = $Bug        # Reference to the bug AnimatedSprite2D

# Function to handle the ball's collision and bounces
func _on_body_entered(body: Node2D) -> void:
	bounce_count += 1
	print("Bounce Count: ", bounce_count, "/", max_bounces)
	
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
	shield_sprite.play("spawn")
	
	# Await for 1.5 seconds before modifying gravity scale
	await get_tree().create_timer(1.2).timeout  # Use create_timer to await the timeout
	
	gravity_scale = 0.856  # Set the gravity scale to the desired value after the delay

	# Randomly move left or right
	linear_velocity = Vector2(150 * (1 if randi() % 2 == 0 else -1), 0)
	shield_sprite.play("idle")

# Make the Bug spin as it bounces
func _physics_process(delta: float) -> void:
	# Adjust the rotation speed to control the spin rate of the bug
	bug_sprite.rotation += 3 * delta  # Rotate the bug sprite
