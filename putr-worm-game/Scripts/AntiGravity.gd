# Area2D script to slow down player fall speed
extends Area2D

@export var slow_gravity: float = 50.0  # New gravity value inside the area
@export var fall_speed: float = 10.0
@export var reduced_jump_velocity: float = -80.0

func _on_area_entered(body):
	if body is CharacterBody2D:
		body.gravity = slow_gravity
		body.velocity.y = fall_speed
		body.JUMP_VELOCITY = reduced_jump_velocity


func _on_area_exited(body):
	if body is CharacterBody2D:
		body.gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		body.JUMP_VELOCITY = -320.0
