extends Area2D

@export var speed = 1000.0  # Bullet speed
var direction = Vector2.ZERO

func _ready():
	set_process(true) 
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))  

func set_direction(target_position: Vector2):
	direction = (target_position).normalized()  # Use the direction set from the player

func _process(delta):
	global_position += direction * speed * delta  # Move in the direction set

func _on_Area2D_body_entered(body):
	if body.is_in_group("tilemap"):  
		queue_free()  
	if body.is_in_group("bug"):  
		queue_free()  

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("tilemap"):
		queue_free()
	elif area.is_in_group("bug"):
		queue_free()
	else:
		pass
