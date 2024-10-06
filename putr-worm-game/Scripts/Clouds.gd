extends Node2D

@export var cloud_speed: float = 10.0
@export var cloud_texture_width: int = 688  # Width of your cloud texture in pixels

var cloud_sprites: Array[Sprite2D] = []

func _ready():
	# Get all child nodes and filter for Sprite2D nodes only
	for child in get_children():
		if child is Sprite2D:
			cloud_sprites.append(child)
	
	if cloud_sprites.size() < 2:
		push_error("You need at least two sprites to create a seamless loop!")

func _process(delta: float):
	# Move clouds to the left
	for sprite in cloud_sprites:
		sprite.position.x -= cloud_speed * delta
		
		# If the sprite moves completely off screen, move it to the right
		if sprite.position.x < -cloud_texture_width:
			sprite.position.x += cloud_texture_width * 2
