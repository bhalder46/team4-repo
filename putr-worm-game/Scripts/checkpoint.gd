extends Area2D

signal checkpoint_activated(position: Vector2)

@export var bobbing_distance: float = 5.0  # Distance to bob
@export var bobbing_speed: float = 2.0      # Bobbing speed
@export var bobbing_horizontal: bool = false  # Enable horizontal bobbing

var time_passed: float = 0.0
var initial_position: Vector2
var bobbing_enabled: bool = false  # Controls when bobbing starts
var has_activated: bool = false  # Flag to track activation state

func _ready() -> void:
	initial_position = $AnimatedSprite2D.position  


func _process(delta: float) -> void:
	if bobbing_enabled:  # Only bob when enabled
		time_passed += delta * bobbing_speed
		var offset = sin(time_passed) * bobbing_distance
		if bobbing_horizontal:
			$AnimatedSprite2D.position.x = initial_position.x + offset
		else:
			$AnimatedSprite2D.position.y = initial_position.y + offset

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("players"):
		emit_signal("checkpoint_activated", global_position)
		print("Checkpoint activated")


func _on_animated_sprite_2d_animation_finished() -> void:
	bobbing_enabled = true  # Enable bobbing after animation finishes
	$fire.play("fireSpawn")
	await get_tree().create_timer(1.5).timeout
	$fire.play("idle")


#Aesthetics method
func _on_area_2d_body_entered(body: Node2D) -> void:
	if not has_activated:  # Only trigger if not already activated
		$Area2D.monitoring = false

		if body.is_in_group("players") and $Area2D.monitoring:
			$AnimatedSprite2D.play("startup")
			$PointLight2D.visible = true
			$Area2D.monitoring = false
			has_activated = true  # Set the flag to true to prevent further activation
