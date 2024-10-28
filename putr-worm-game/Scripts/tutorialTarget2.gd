extends Node  # Not an Area2D node, just a regular Node

var is_active = false  # Track if the dialog is currently active

# Called when the node is added to the scene
func _ready():
	# Connect the area_entered signal from Area2D to this script
	$Target/Area2D.connect("area_entered", Callable(self, "_on_Area2D_area_entered"))
	$Target/Area2D.connect("area_exited", Callable(self, "_on_Area2D_area_exited"))
	Dialogic.signal_event.connect(timelineEnd4)  # Ensure this is correctly connected

# Signal handler for the area_entered signal
func _on_Area2D_area_entered(area):
	# Check if the dialog is currently active
	if is_active:
		print("Dialog is already active, no action taken.")
		return

	print("Area entered: ", area.name)

	# Get the player node
	var player = get_node("/root/Game/Player")  # Adjust the path as needed

	# Check if the player exists
	if player:
		player.disable_movement = true  # Disable player movement
		player.disable_shooting = true   # Disable player shooting

	# Check if the incoming area is in the "bullet" group
	if area.is_in_group("bullet"):
		print("Bullet detected! Destroying target.")
		
		# Queue the current Node for deletion
		self.visible = false  # Or set it to 0 if using CanvasItem
		
		Dialogic.start("test")  # Start the dialog
		is_active = true  # Mark the dialog as active

	else:
		print("Not bullet")

func timelineEnd4(argument: String):
	if is_active:
		print("Dialog ended: ", argument)
		var player = get_node("/root/Game/Player")  # Adjust the path as needed
		if player:
			print("Re-enabling player controls.")  # Debug output
			if argument == "test":
				# Enable player's movement and shooting after dialog ends
				player.disable_movement = false  # Enable movement
				player.disable_shooting = false  # Enable shooting

		# Turn off the Area2D monitoring
		is_active = false  # Reset the active state after the dialog ends
		$Target/Area2D.disconnect("area_entered", Callable(self, "_on_Area2D_area_entered"))
		$Target/Area2D.disconnect("area_exited", Callable(self, "_on_Area2D_area_exited"))

func _on_Area2D_area_exited(area):
	# Optional: Handle any cleanup or reset logic if needed when the area is exited
	print("Area exited: ", area.name)
