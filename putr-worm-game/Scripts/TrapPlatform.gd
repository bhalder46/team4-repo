extends StaticBody2D

@export var disappear_time: float = 1.0  # Time for fade out animation
@export var reappear_time: float = 2.0   # Delay before reappearing

var anim_player: AnimationPlayer  # Declare the variable

func _ready() -> void:
	anim_player = $AnimationPlayer  # Initialize the anim_player variable
	$Sprite2D.modulate.a = 1  # Set the opacity to fully visible at the start
	print("Platform ready and fully visible.")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and $Area2D.monitoring:  # Ensure Area2D monitoring is enabled
		print("Player entered the platform.")
		start_disappear_cycle()

func start_disappear_cycle() -> void:
	$Area2D.set_deferred("monitoring", false)  # Temporarily stop monitoring using set_deferred
	anim_player.play("fade_out")
	print("Platform is disappearing...")
	

	# Wait for the fade out animation to finish
	await anim_player.animation_finished
	$CollisionShape2D.disabled = true  # Disable collision after fade out
	print("Platform collision disabled.")

	# Wait for reappear delay
	await get_tree().create_timer(reappear_time).timeout
	print("Waiting to reappear...")

	# Start fade in animation
	anim_player.play("fade_in")

	# Wait for fade in animation to finish
	await anim_player.animation_finished
	$CollisionShape2D.disabled = false  # Re-enable collision after fade in
	print("Platform reappeared and collision re-enabled.")

	# Re-enable monitoring after 4 seconds using set_deferred
	await get_tree().create_timer(0.1).timeout
	$Area2D.set_deferred("monitoring", true)
	print("Area2D monitoring re-enabled.")
