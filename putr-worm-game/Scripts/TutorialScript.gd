extends Area2D

# This flag tracks if the current Area2D is in control of disabling player actions
var is_active = false
var has_been_activated = false  # New flag to track if the area has been activated
@onready var pause_menu = get_node("/root/Game/PauseLayer/Pause_Menu")

func _ready():
	Dialogic.signal_event.connect(timelineEnd1)  # Connect the signal to the function

func _on_body_entered(body):
	if body.name == "Player" and not has_been_activated:  # Check if it has been activated before
		pause_menu.can_pause = false
		print("Player entered the area.")
		has_been_activated = true  # Set the flag to indicate the area has been activated
		is_active = true  # This Area2D is now active
		# Disable movement and shooting when the timeline starts
		body.disable_movement = true
		body.disable_shooting = true
		Dialogic.start("TutorialGeneral")

func _on_body_exited(body):
	if body.name == "Player":
		print("Player exited the area.")
		is_active = false  # This Area2D is no longer active
		# Optionally enable movement and shooting when leaving the area
		body.disable_movement = false
		body.disable_shooting = false

func timelineEnd1(argument: String):
	# Check if this Area2D is active before changing the player's state
	if is_active:
		if argument == "end1":
			pause_menu.can_pause = true
			print("End")
			var player = get_node("/root/Game/Player")  # Adjust the path to your player node as needed
			if player:
				# Control player's movement and shooting based on the timeline ending
				player.disable_movement = false  # Enable movement after timeline ends
				player.disable_shooting = true  # Disable shooting after timeline ends
