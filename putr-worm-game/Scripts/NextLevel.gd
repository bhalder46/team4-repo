extends Sprite2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":  # Check if it is the player
		print("Player entered the Area2D")  # Debug print
		var next_scene = "res://Scenes/NetworkProto.tscn"
		get_tree().change_scene_to_file(next_scene)
