extends Control

@onready var animation_player = $AnimationPlayer

func _on_start_pressed():
	print("Start pressed")
	# Play the intro animation
	animation_player.play("menuIntro")


func _on_exit_pressed():
	print("Exit pressed")
	get_tree().quit()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "menuIntro":
		# Change the scene when the intro animation finishes
		get_tree().change_scene_to_file("res://Scenes/Levels/introCutscene.tscn")
