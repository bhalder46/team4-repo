extends Node2D

# Set player_node_path directly to "/root/Game/Player"
var player_node_path: NodePath = "/root/Game/Player"

# Variables to access the player and teleporter nodes
var player
var entrance_area
var entrance_position
var exit_area
var exit_position
var teleport_cooldown = false # Cooldown flag to prevent immediate re-teleportation

func _ready():
	# Get references to the player and necessary nodes
	player = get_node(player_node_path)
	entrance_area = $PortalEntrance/Area2D
	entrance_position = $PortalEntrance.global_position
	exit_area = $PortalExit/Area2D
	exit_position = $PortalExit.global_position

	# Check if the player and necessary areas are valid
	if player == null:
		push_error("Player node not found at '/root/Game/Player'. Check the node path.")
		return
	if entrance_area == null:
		push_error("Entrance area not found. Check PortalEntrance/Area2D path.")
		return
	if exit_area == null:
		push_error("Exit area not found. Check PortalExit/Area2D path.")
		return

func _process(delta):
	# Check for teleportation every frame
	if teleport_cooldown:
		return

	if entrance_area.overlaps_body(player):
		player.global_position = exit_position
		start_teleport_cooldown() # Start cooldown after teleporting

	elif exit_area.overlaps_body(player):
		player.global_position = entrance_position
		start_teleport_cooldown() # Start cooldown after teleporting

# Function to start teleport cooldown
func start_teleport_cooldown():
	teleport_cooldown = true
	await get_tree().create_timer(1).timeout # 1-second delay
	teleport_cooldown = false
