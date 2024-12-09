extends Area2D

# This flag tracks if the current Area2D is in control of disabling player actions
var is_active = false
# This flag tracks if area monitoring should be turned off
var area_monitoring_active = true

@onready var pause_menu = get_node("/root/Game/PauseLayer/Pause_Menu")

func _ready():
	Dialogic.signal_event.connect(timelineEnd3)  # Connect the signal to the function

func _on_body_entered(body):
	if body.name == "Player" and area_monitoring_active:
		pause_menu.can_pause = false
		print("Player entered the area.")
		is_active = true  # This Area2D is now active
		body.disable_movement = true
		body.disable_shooting = true
		Dialogic.start("TutorialGeneralTarget1")

func timelineEnd3(argument: String):
	# Check if this Area2D is active before changing the player's state
	if is_active:
		print("End")
		var player = get_node("/root/Game/Player")  # Adjust the path to your player node as needed
		if player:
			if argument == "end3":
				pause_menu.can_pause = true
				# Control player's movement and shooting based on the current timeline
				player.disable_movement = true  # Enable movement after timeline ends
				player.disable_shooting = false  # Disable shooting, can be adjusted

		# Disable area monitoring since the timeline has ended
		is_active = false
		area_monitoring_active = false  # Turn off area monitoring
