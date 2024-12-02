extends Area2D

# Variable to store the dialog name, editable in the Inspector
@export var dialog_name: String = "DefaultDialog"

var is_active = false
var has_been_activated = false

# Connects the dialog signal
@onready var dialogic = Dialogic  # Assuming Dialogic is already globally available.

func _ready():
	# Connects the dialog signal
	dialogic.signal_event.connect(timelineEnd5)

func _process(delta):
	pass

func _on_body_entered(body):
	# Check if the player has entered the area and the dialogue hasn't been triggered yet
	if body.name == "Player" and not has_been_activated:
		print("Player entered the area.")
		is_active = true  # Enable the ability to interact with the area
		Dialogic.start(dialog_name)

func _on_body_exited(body):
	# Check if the player exited the area
	if body.name == "Player":
		print("Player exited the area.")
		is_active = false  # Disable interaction with the area

func start_dialog():
	has_been_activated = true
	is_active = true
	
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
		if player:
			player.disable_movement = false
			player.disable_shooting = false
		
		# Reset activation states here to ensure it only happens after the timeline ends
		is_active = false
		has_been_activated = true
