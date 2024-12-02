extends Area2D

# This flag tracks if the current Area2D is in control of disabling player actions
var is_active = false
var has_been_activated = false

@export var dialog_name_new: String = "DefaultDialog"

func _ready():
	Dialogic.signal_event.connect(timelineEnd5)  # Connect the signal to the function

func _on_body_entered(body):
	if body.name == "Player" and not has_been_activated:
		print("Player entered the area.")
		has_been_activated = true
		is_active = true  # This Area2D is now active
		body.disable_movement = true
		body.disable_shooting = true
		Dialogic.start(dialog_name_new)

func _on_body_exited(body):
	if body.name == "Player":
		print("Player exited the area.")
		is_active = false  # This Area2D is no longer active
		body.disable_movement = false
		body.disable_shooting = false

func timelineEnd5(argument: String):
	# Check if this Area2D is active before changing the player's state
	if is_active:
		if argument == "end5":
			print("End")
			# Control player's movement and shooting based on the timeline ending
			var player = get_node("/root/Game/Player")  # Adjust this if the path is different
			if player:
				player.disable_movement = false  # Enable movement after timeline ends
				player.disable_shooting = false  # Enable shooting after timeline ends
