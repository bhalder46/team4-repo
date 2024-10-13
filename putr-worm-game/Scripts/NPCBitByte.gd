extends Area2D

var player_in_area = false
var has_spoken_to_npc = false  # Track player interaction

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	monitoring = true  # Ensure monitoring is enabled when ready

	# Connect the Dialogic signals
	Dialogic.connect("dialogue_started", Callable(self, "_on_dialogue_started"))
	Dialogic.connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact"):  # 'E' mapped to "ui_accept"
		monitoring = false  # Disable monitoring
		print("Area2D disabled")
		Dialogic.start("BitByteDialogue")  # Start the single timeline

# When the player enters the area
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = true

# When the player exits the area
func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = false

# Function to be called when dialogue starts
func _on_dialogue_started():
	print("Dialogue started.")  # Debug message

# Function to be called when dialogue ends
func _on_dialogue_finished(argument: String):
	print("Dialogue ended with argument: ", argument)  # Debug message
	if argument == "dialogue_finished":
		monitoring = true  # Re-enable monitoring
		print("Area2D Enabled")  # Debug message
