extends Control

@onready var checkpoint_button = $HBoxContainer/Respawn
@onready var resume_button = $HBoxContainer/Resume
@onready var exit_button = $HBoxContainer/Quit

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
   

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	visible = !visible
	get_tree().paused = visible

func _on_respawn_pressed():
	var player = get_tree().get_first_node_in_group("players")
	
	if player:
		player.respawn() 
		toggle_pause()

func _on_resume_pressed():
	print("Resume pressed")
	toggle_pause()
	

func _on_exit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Levels/main_menu.tscn")
