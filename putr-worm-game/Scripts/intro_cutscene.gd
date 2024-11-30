extends Node2D

@onready var introMusic: AudioStreamPlayer2D = $introMusic
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	introMusic.play(10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called when an animation finishes playing.
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro": 
		get_tree().change_scene_to_file("res://scenes/Levels/Tutorial.tscn")
