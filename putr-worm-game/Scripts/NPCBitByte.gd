extends Area2D

# Variable to store the dialog name, editable in the Inspector
@export var dialog_name: String = "DefaultDialog"

var is_active = false
var has_been_activated = false
@onready var e_key = $EKey  # Correct path for EKey

@onready var pause_menu = get_node("/root/Game/PauseLayer/Pause_Menu")

func _ready():
	# Debug print to check if e_key is initialized correctly
	print("Debug: e_key =", e_key)
	
	if e_key:
		e_key.modulate.a = 0.0  # Start with e_key fully transparent
	else:
		print("Debug: e_key is null. Check the node path or hierarchy.")

	# Connects the dialog signal
	Dialogic.signal_event.connect(timelineEnd5)

func _process(delta):
	if is_active and not has_been_activated and Input.is_action_just_pressed("interact"):
		start_dialog()

func _on_body_entered(body):
	if body.name == "Player" and not has_been_activated:
		print("Player entered the area.")
		is_active = true
		
		if e_key:
			fade_in_e_key()
		else:
			print("Debug: e_key is null in _on_body_entered.")

func _on_body_exited(body):
	if body.name == "Player":
		print("Player exited the area.")
		is_active = false
		
		if e_key:
			fade_out_e_key()
		else:
			print("Debug: e_key is null in _on_body_exited.")

func start_dialog():
	pause_menu.can_pause = false
	has_been_activated = true
	is_active = true
	
	if e_key:
		fade_out_e_key()  # Hide E Key during dialog
	else:
		print("Debug: e_key is null in start_dialog.")
	
	var player = get_node("/root/Game/Player")
	if player:
		player.disable_movement = true
		player.disable_shooting = true
	
	# Start dialog using the export variable
	Dialogic.start(dialog_name)

func timelineEnd5(argument: String):
	if is_active and argument == "end5":
		print("End of dialogue reached, restoring control.")
		
		var player = get_node("/root/Game/Player")
		pause_menu.can_pause = true
		if player:
			player.disable_movement = false
			player.disable_shooting = false
		
		# Only reset activation states here to ensure it only happens after the timeline ends
		is_active = false
		has_been_activated = true
		
	if e_key:
		e_key.modulate.a = 0.0  # Ensure E key is hidden after dialogue

# Function to fade in the E key
func fade_in_e_key():
	if e_key:
		e_key.visible = true
		e_key.modulate.a = 0.0  # Start transparent
		e_key.create_tween().tween_property(e_key, "modulate:a", 1.0, 0.5)  # Fade in over 0.5 seconds

# Function to fade out the E key
func fade_out_e_key():
	if e_key:
		e_key.create_tween().tween_property(e_key, "modulate:a", 0.0, 0.5)  # Fade out over 0.5 seconds
