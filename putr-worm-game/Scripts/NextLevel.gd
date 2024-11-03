extends Sprite2D

# Export a variable so the scene path can be set in the editor
@export var next_scene: String = "res://Scenes/levelOneNetwork.tscn"
# Reference to the AnimationPlayer node
@onready var animation_player: AnimationPlayer = $AnimationPlayerFadeOut

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

# Called after the delay
func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "transitionFadeOut":
		get_tree().change_scene_to_file(next_scene)
