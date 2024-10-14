extends Node2D

@onready var music_player = $ForestMusic  
@onready var music_player2 = $ForestAmbience
@onready var player = $Player  # Adjust the path to your player node
@onready var health_ui = $HealthUI

func _ready() -> void:
	# Play the music when the scene starts
	if music_player:
		music_player.play()
		
	if music_player2:
		music_player2.play()
	
		# Connect the player's health_changed signal to the UI's update function
	if player and health_ui:
		player.health_changed.connect(health_ui.update_hearts)
	
	# Initialize the UI with the player's current health
	health_ui.update_hearts(player.current_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass  # Replace with function body.
