extends Node2D  # ScrollAttempt is a Node2D

var scroll_speed = 150  # Adjust to your desired scroll speed
var texture_height = 640  # Set the height of your texture (in pixels)

var sprite1: Sprite2D
var sprite2: Sprite2D

func _ready():
	scroll_speed = randf_range(80, 180)
	# Now Sprite1 and Sprite2 are children of this Node2D (ScrollAttempt)
	sprite1 = $Sprite1
	sprite2 = $Sprite2
	
	# Position the second sprite directly above the first
	sprite2.position.y = sprite1.position.y - texture_height

func _process(_delta):
	# Move both sprites downward
	sprite1.position.y += scroll_speed * _delta
	sprite2.position.y += scroll_speed * _delta
	
	# Check if the first sprite has moved off-screen, then reset its position
	if sprite1.position.y >= texture_height:
		sprite1.position.y = sprite2.position.y - texture_height
	
	# Check if the second sprite has moved off-screen, then reset its position
	if sprite2.position.y >= texture_height:
		sprite2.position.y = sprite1.position.y - texture_height
