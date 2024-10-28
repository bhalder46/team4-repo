extends Sprite2D

# Export a variable so the scene path can be set in the editor
@export var next_scene: String = "res://Scenes/levelOneNetwork.tscn"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":  # Check if it is the player
		print("Player entered the Area2D")  # Debug print
		if next_scene != "":
			get_tree().change_scene_to_file(next_scene)
		else:
			print("No scene assigned to 'next_scene'")
