extends Area2D

@onready var darkness_shader_material: ShaderMaterial = $darkness/ColorRect5.material
@onready var shadow_shader_material: ShaderMaterial = $shadow.material

var outer_radius_target = 5.0
var main_alpha_target = 0.0
var fade_factor_target = 1.0  # Initial fade factor target
var outer_radius = 5.0
var main_alpha = 0.0
var fade_factor = 1.0  # Set fade factor to 1 when the shadow spawns
const TRANSITION_SPEED = 4.0  # Adjust speed for smooth transitions

# Use @onready to ensure the fade factor is set to 1 when the node is ready
@onready var _set_initial_fade_factor = set_initial_fade_factor()

# Function to set fade factor initially to 1
func set_initial_fade_factor():
	fade_factor = 1.0
	shadow_shader_material.set_shader_parameter("fade_factor", fade_factor)

func _process(delta: float) -> void:
	outer_radius = lerp(outer_radius, outer_radius_target, delta * TRANSITION_SPEED)
	main_alpha = lerp(main_alpha, main_alpha_target, delta * TRANSITION_SPEED)
	fade_factor = lerp(fade_factor, fade_factor_target, delta * TRANSITION_SPEED)  # Smoothly transition fade_factor

	darkness_shader_material.set_shader_parameter("outerRadius", outer_radius)
	darkness_shader_material.set_shader_parameter("MainAlpha", main_alpha)
	shadow_shader_material.set_shader_parameter("fade_factor", fade_factor)  # Update fade_factor in shadow shader

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		outer_radius_target = 1.0
		main_alpha_target = 1.0
		fade_factor_target = 0.0  # Set fade_factor to 0 when entering

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		outer_radius_target = 5.0
		main_alpha_target = 0.0
		fade_factor_target = 1.0  # Set fade_factor to 1 when exiting
