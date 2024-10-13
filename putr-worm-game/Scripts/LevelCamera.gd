extends Area2D
# Reference to the player's camera
@onready var player_camera = get_node("/root/Game/Player/PlayerCamera")  # Adjust the path if needed

# Variable to store the area camera dynamically
var current_area_camera: Camera2D = null

func _ready():
	# Set the player camera as the default camera at the start
	player_camera.make_current()
	print("Player camera is set as the current camera.")

func _on_body_entered(body: Node2D) -> void:
	# Check if the body that entered is the Player node
	if body.name == "Player":
		print("Player entered the area. Switching to area camera.")
		# Get the AreaCamera node dynamically
		current_area_camera = $Camera2D  # Assuming the Camera2D is a child of this Area2D
		current_area_camera.make_current()

func _on_body_exited(body: Node2D) -> void:
	# Check if the body that exited is the Player node
	if body.name == "Player":
		print("Player exited the area. Switching back to player camera.")
		# Switch back to the player camera
		player_camera.make_current()
		current_area_camera = null
