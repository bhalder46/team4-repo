extends RigidBody2D

@onready var collision_shape = $CollisionShape2D
@onready var red_bug_death = $redBugDeath
@onready var sprite = $redBugSprite

@onready var bird = $"/root/Game/Bird"



# Variable to store the speed factor for animation
var speed_factor: float

func _ready() -> void:
	# Randomly assign a speed factor between a desired range (e.g., 0.5 to 1.5)
	speed_factor = randf_range(0.5, 2)
	sprite.speed_scale = speed_factor

func _on_area_2d_area_entered(area: Area2D) -> void:
	# Check if the Area2D is in the 'bullet' group
	if not area.is_in_group("bullet"):
		return  # Skip the logic if it's not in the group

	# Queue free the bullet
	area.queue_free()

	# Check if the bird's red_buff_active is true
	if not bird.red_buff_active:
		return  # Skip the logic if red_buff_active is not true

	# Check if the collision shape is disabled
	if collision_shape.disabled:
		return  

	print("Bug collision entered")

	# Hide the sprite and disable the collision shape
	sprite.visible = false
	collision_shape.disabled = true

	# Play the death animation
	red_bug_death.play("death")

	# Wait for the animation to finish before deleting the object
	await get_tree().create_timer(0.4).timeout  # Wait for the death animation duration

	print("Red bug death")

	# Free the body after the animation finishes
	queue_free()
