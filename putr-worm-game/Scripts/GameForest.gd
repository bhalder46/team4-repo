extends Node2D

@onready var music_player = $ForestMusic  
@onready var music_player2 = $ForestAmbience
@onready var player = $Player  # Adjust the path to your player node
@onready var health_ui: Control = $Player/Camera2D/HealthUI

#Load the checkpoint scene
@export var checkpoint_scene: PackedScene  # Assuming you have a checkpoint scene

# Load the Spike scene
@export var spike_scene: PackedScene

func _ready() -> void:
	# Play the music when the scene starts
	if music_player:
		music_player.play()
		
	if music_player2:
		music_player2.play()
	
		# Connect the player's health_changed signal to the UI's update function
	if player and health_ui:
		player.health_changed.connect(health_ui.update_hearts)
	
	# Connect all checkpoints in the scene to the player's update_checkpoint function
	for checkpoint in get_tree().get_nodes_in_group("Checkpoints"):
		checkpoint.checkpoint_activated.connect(player.update_checkpoint)

	if spike_scene:
		var spike_instance = spike_scene.instantiate()
		add_child(spike_instance)
		spike_instance.position = Vector2(400,600)
	
	# Initialize the UI with the player's current health
	health_ui.update_hearts(player.current_health)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass  # Replace with function body.
