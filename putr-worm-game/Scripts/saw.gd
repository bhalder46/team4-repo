extends Node2D

const Player = preload("res://Scripts/player.gd")

@export var speed: float = 100
@export var distance: float = 300
@export var vertical: bool = false
@export var rotation_speed: float = 575.0

var direction: int = 1
var start_position: Vector2

func _ready():
	start_position = position

func _process(delta):
	rotation += deg_to_rad(rotation_speed) * delta

	# Use precise movement based on distance traveled
	if vertical:
		position.y += speed * direction * delta
		if abs(position.y - start_position.y) >= distance:
			position.y = start_position.y + direction * distance  # Align exactly to boundary
			direction *= -1
	else:
		position.x += speed * direction * delta
		if abs(position.x - start_position.x) >= distance:
			position.x = start_position.x + direction * distance  # Align exactly to boundary
			direction *= -1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
