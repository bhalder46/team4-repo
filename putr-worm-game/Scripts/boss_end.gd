extends Node2D

@onready var endMusic: AudioStreamPlayer2D = $endMusic



func _ready() -> void:
	CameraShakeGlobalSingleton.screenshake_long()
	
	endMusic.play(10.0)

	
	await get_tree().create_timer(3.0).timeout
	CameraShakeGlobalSingleton.screenshake_stop()

	
func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "deathBoss": 
		get_tree().change_scene_to_file("res://scenes/Levels/introCutscene.tscn")
		
