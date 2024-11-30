extends Node2D

@onready var RedLight = $RedLight

# Called when the node enters the scene tree for the first time
func _ready():
	# Ensure RedLight's material is of type ShaderMaterial before accessing
	if RedLight.material and RedLight.material is ShaderMaterial:
		RedLight.material.set_shader_parameter("intensity", 0)
		print("Initial parameter set to 0")
	
	# Gradually increase the intensity from 0 to 5 over 2 seconds
	await gradually_increase_intensity(2, 1.5)

# Gradually increases the intensity from 0 to target over a given time
func gradually_increase_intensity(target, duration):
	var start_value = 0
	var elapsed_time = 0.0
	
	while elapsed_time < duration:
		# Lerp the intensity value
		var current_value = lerp(start_value, target, elapsed_time / duration)
		# Update the shader parameter
		if RedLight.material and RedLight.material is ShaderMaterial:
			RedLight.material.set_shader_parameter("intensity", current_value)
		# Wait for the next frame
		await get_tree().create_timer(0.01).timeout
		elapsed_time += 0.01
	
	# Ensure we set the final value exactly to the target
	if RedLight.material and RedLight.material is ShaderMaterial:
		RedLight.material.set_shader_parameter("intensity", target)
		print("Final intensity set to ", target)
