extends Node2D

@onready var music_player = $NetworkMusic  # Reference to the AudioStreamPlayer node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Play the music when the scene starts
	if music_player:
		music_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass  # Replace with function body.
