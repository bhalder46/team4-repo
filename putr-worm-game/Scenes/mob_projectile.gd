extends Area2D

var speed = 300
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
