extends Control


@export var full_heart_texture: Texture2D
@export var empty_heart_texture: Texture2D

@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3
]

@onready var death_counter_label: Label = $DeathCounterLabel


func _ready():
	update_hearts(3)  # Initialize with full hearts
	update_death_counter()

# Function to update the heart display
func update_hearts(current_health: int) -> void:
	for i in range(hearts.size()):
		if i < current_health:
			hearts[i].texture = full_heart_texture
		else:
			hearts[i].texture = empty_heart_texture

func update_death_counter() -> void:
	death_counter_label.text = "Deaths: %d" % DeathCounter.death_count

# Call this function whenever the player dies
func on_player_death() -> void:
	DeathCounter.death_count += 1
	update_death_counter()
	
