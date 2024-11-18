extends Area2D

@onready var glitchRect = $glitchRect
@onready var NetworkMusic = get_node("/root/Game/NetworkMusic")

var boss_scene = preload("res://Scenes/bossVirus.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": # Ensure it's the player entering
		await get_tree().create_timer(5.0).timeout # Wait 8 seconds
		glitchRect.visible = true # Make glitchRect visible
		call_bird_remove()
		await get_tree().create_timer(0.3).timeout # Wait 0.3 seconds
		spawn_boss(Vector2(-1630.98, 870.918)) # Spawn boss at given position
		glitchRect.visible = false # Hide glitchRect

		if NetworkMusic:
			NetworkMusic.stop() # Stop the music
		else:
			print("NetworkMusic node not found!")
		

func call_bird_remove() -> void:
	# Check if the Bird node exists
	var bird = get_node("/root/Game/Bird")
	if bird:
		print("Found Bird! Calling remove.")
		bird.remove()  # Call the Bird's remove method
	else:
		print("Bird node not found!")


func spawn_boss(position: Vector2) -> void:
	var boss_instance = boss_scene.instantiate()
	boss_instance.position = position
	get_tree().root.get_node("Game").add_child(boss_instance)