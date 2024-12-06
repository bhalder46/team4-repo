extends Control


func _on_start_pressed():
	print("Start pressed")
	get_tree().change_scene_to_file("res://Scenes/Levels/introCutscene.tscn")


func _on_settings_pressed():
	print("Settings pressed")


func _on_exit_pressed():
	print("Exit pressed")
	get_tree().quit()
