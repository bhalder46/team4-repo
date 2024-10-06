extends Node2D

@onready var music_player = $ForestMusic  # Reference to the AudioStreamPlayer node
@onready var music_player2 = $ForestAmbience
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Play the music when the scene starts
	if music_player:
		music_player.play()
		
	if music_player2:
		music_player2.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass  # Replace with function body.
