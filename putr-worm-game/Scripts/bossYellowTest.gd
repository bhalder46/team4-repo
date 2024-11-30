extends RigidBody2D

# A flag to check if the first bounce has occurred.
var has_bounced = false

func _ready():
	# Ensure the body is initially frozen.
	linear_velocity = Vector2.ZERO
	sleeping = true  # This ensures it starts in a "frozen" state.

func _unfreeze():
	# Unfreeze the body and let it fall.
	sleeping = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Ensure the object falls straight down with no initial horizontal velocity.
	if not has_bounced and state.linear_velocity.x != 0:
		state.linear_velocity.x = 0  # Keep it falling straight vertically.

func _on_body_entered(body: Node):
	if not has_bounced:
		# This code runs only on the first collision.
		has_bounced = true

		# Apply a random horizontal impulse to create the left or right bounce.
		var random_direction = randf_range(-1.0, 1.0)
		var horizontal_impulse = Vector2(random_direction * 200, 0)  # Adjust the multiplier as needed.
		apply_impulse(Vector2.ZERO, horizontal_impulse)

		# Optionally, adjust the bounciness/restitution.
		if physics_material:
			physics_material.bounce = 0.5  # Adjust the bounce factor as needed.

# Connect the body_entered signal in the Godot Editor or via code:
# self.connect("body_entered", self, "_on_body_entered")

# Call _unfreeze() when you want to start the simulation, e.g., from another script or game logic.
