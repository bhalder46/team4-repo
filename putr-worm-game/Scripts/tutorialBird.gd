extends Area2D


var BirdScene: PackedScene  # Declare a variable to hold the Bird scene
var is_active = false        # Track if this Area2D is active
var has_been_activated = false  # New flag to track if the area has been activated

func _ready():
	Dialogic.signal_event.connect(timelineEnd2)  # Connect the signal to the function
	Dialogic.signal_event.connect(spawn_bird)     # Connect the bird signal to the spawn function

	# Load the Bird scene from the scenes folder
	BirdScene = preload("res://Scenes/Bird.tscn")  # Make sure this path is correct

func _on_body_entered(body):
	if body.name == "Player" and not has_been_activated:  # Check if it has been activated before
		print("Player entered the area.")
		has_been_activated = true  # Set the flag to indicate the area has been activated
		is_active = true  # Mark this Area2D as active
		# Disable movement and shooting when the timeline starts
		body.disable_movement = true
		body.disable_shooting = true
		Dialogic.start("redBugs")

func _on_body_exited(body):
	if body.name == "Player":
		print("Player exited the area.")
		is_active = false  # Mark this Area2D as inactive
		# Optionally keep shooting disabled when exiting the area
		body.disable_movement = false
		body.disable_shooting = false  # Keep shooting disabled

func timelineEnd2(argument: String):
	# Only modify the player state if this Area2D is the active one
	if is_active and argument == "end2":
		print("End")
		var player = get_node("/root/Game/Player")  # Adjust the path to your player node as needed
		if player:
			# Re-enable movement and optionally keep shooting disabled
			player.disable_movement = false
			player.disable_shooting = false  # Keep shooting disabled

func spawn_bird(argument: String):
	# Only spawn the bird if this Area2D is active and the signal argument matches
	if is_active and argument == "bird":
		print("Spawning bird")
		var bird_instance = BirdScene.instantiate()  # Instantiate the Bird scene
		bird_instance.position = Vector2(-570, -35)  # Set the position
		get_tree().root.get_node("Game").add_child(bird_instance)  # Add the instance to the Game node
