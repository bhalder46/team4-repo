extends Area2D

# Reference to the player's camera
@onready var player_camera = get_node("/root/Game/Player/PlayerCamera")  # Adjust if needed

# Reference to the area camera
@onready var area_camera = get_node("/root/Game/AreaCamera/Camera2D")  # Ensure this matches your node structure

func _ready():
	# Set the player camera as the current camera at the start
	player_camera.make_current()  
	print("Player camera is set as the current camera.")



func _on_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name)  # Debug print to show which body entered
	# Check if the body that entered is the Player node
	if body.name == "Player":  # Ensure the node's name is "Player"
		print("Player entered the area. Switching to area camera.")
		area_camera.make_current()  # Activate the area camera


func _on_body_exited(body: Node2D) -> void:
	print("Body exited: ", body.name)  # Debug print to show which body exited
	# Check if the body that exited is the Player node
	if body.name == "Player":  # Ensure the node's name is "Player"
		print("Player exited the area. Switching back to player camera.")
		player_camera.make_current()  # Reactivate the player camera
