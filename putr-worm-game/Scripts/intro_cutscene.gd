extends Node2D

@onready var introMusic: AudioStreamPlayer2D = $introMusic

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	introMusic.play(10)

# Called when an animation finishes playing.
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("Animation finished:", anim_name)
	if anim_name == "intro": 
		print("Changing scene to Tutorial2")
		var scene_path = "res://Scenes/Levels/Tutorial2.tscn"
		if ResourceLoader.exists(scene_path):
			get_tree().change_scene_to_file(scene_path)
		else:
			print("Error: Scene path does not exist:", scene_path)
