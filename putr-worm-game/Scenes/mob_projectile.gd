extends Area2D

var speed = 200
var direction = Vector2.ZERO

func _ready():
	pass

func _physics_process(delta):
	position += direction * speed * delta

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	rotation = direction.angle()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# Signal handler for when the bug enemy enters another body
func _on_body_entered(body):
	if body.is_in_group("players"):  # Ensure it's the player
		body.take_damage(1)
	elif body.is_in_group("tilemap"):  # Check if it collides with TileMap group
		queue_free()
