extends AnimatedSprite2D

@export var speed: float = 100.0
@export var move_right: bool = true
@export var move_left: bool = false
@export var move_up: bool = false

@export var min_spin_speed: float = 5.0  # Minimum spin speed (degrees per second)
@export var max_spin_speed: float = 20.0  # Maximum spin speed (degrees per second)

const Player = preload("res://Scripts/player.gd")

var _timer: float = 0.0
const MOVE_DURATION: float = 3.0
var _spin_speed: float = 0.0

func _ready() -> void:
	# Determine spin direction based on movement
	if move_right:
		_spin_speed = randf_range(min_spin_speed, max_spin_speed)  # Clockwise
	elif move_left:
		_spin_speed = randf_range(-max_spin_speed, -min_spin_speed)  # Counterclockwise
	elif move_up:
		_spin_speed = 0  # No spin

func _process(delta: float) -> void:
	# Update position based on the selected direction
	if move_right:
		position.x += speed * delta
	elif move_left:
		position.x -= speed * delta
	elif move_up:
		position.y -= speed * delta
	
	# Apply spin if applicable
	rotation_degrees += _spin_speed * delta

	# Track the movement duration
	_timer += delta
	if _timer >= MOVE_DURATION:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:  # Check if the colliding body is the player
		body.take_damage(1)
