extends Sprite2D

# Export a variable so the scene path can be set in the editor
@export var next_scene: String = "res://Scenes/levelOneNetwork.tscn"
# Reference to the AnimationPlayer node
@onready var animation_player: AnimationPlayer = $AnimationPlayerFadeOut

# Input action to trigger the skip method
@export var skip_input_action: String = "skip"  # You can customize this in the editor

func _process(delta: float) -> void:
	# Check for the "skip" input action
	if Input.is_action_just_pressed(skip_input_action):
		_on_skip_pressed()

# Called when the player enters the Area2D
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":  # Check if it is the player
		print("Player entered the Area2D")  # Debug print
		if next_scene != "":
			# Play the transition animation
			animation_player.play("transitionFadeOut")
			# Wait for 1.5 seconds
			await get_tree().create_timer(1.5).timeout
			_on_animation_finished("transitionFadeOut")
		else:
			print("No scene assigned to 'next_scene'")

# Called after the delay when the animation finishes
func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "transitionFadeOut":
		get_tree().change_scene_to_file(next_scene)

# New method for handling the "skip" input action
func _on_skip_pressed() -> void:
	if next_scene != "":
		# Play the transition animation immediately
		animation_player.play("transitionFadeOut")
		# Wait for 1.5 seconds
		await get_tree().create_timer(1.5).timeout
		_on_animation_finished("transitionFadeOut")
	else:
		print("No scene assigned to 'next_scene'")
