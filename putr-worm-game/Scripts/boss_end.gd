extends Node2D

@onready var endMusic: AudioStreamPlayer2D = $endMusic

@onready var pause_menu = get_parent().get_node("PauseLayer/Pause_Menu")

func _ready() -> void:
	CameraShakeGlobalSingleton.screenshake_long()
	
	endMusic.play(10.0)

	
	await get_tree().create_timer(3.0).timeout
	CameraShakeGlobalSingleton.screenshake_stop()

	
func _process(delta: float) -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "deathBoss": 
		pause_menu.can_pause = true
		get_tree().change_scene_to_file("res://Scenes/Levels/main_menu.tscn")
		
