extends AnimatedSprite2D

# Variable to hold the player reference
var player: CharacterBody2D
var flutter_distance: float = 10.0
var flutter_speed: float = 1.0

# Color states
enum LightColors { BLUE, RED, YELLOW }
var current_color: LightColors = LightColors.BLUE

# Reference to the PointLight2D and Sprite2D nodes
@onready var point_light: PointLight2D = $PointLight2D
@onready var color_sprite: Sprite2D = $Sprite2D  # Reference to the Sprite2D node

# Cooldown timer for buffswitch
var buffswitch_cooldown: float = 0.0
var buffswitch_delay: float = 0.7  # 1 second delay

# Speed, jump, and shoot buffs
var speed_boost: float = 1.2  # 20% speed increase
var jump_boost: float = 1.1  # 10% jump height increase
var shoot_cooldown_boost: float = 0.50

# Track if buffs are active
var yellow_buff_active: bool = false
var blue_buff_active: bool = false


# Function to change the point light color and apply/remove buffs
func _change_light_color():
	match current_color:
		LightColors.BLUE:
			_remove_buff()  # Remove previous buffs
			point_light.color = Color(0, 0, 1)  # Blue
			self.modulate = Color(0.5, 0.5, 1)  # Light Blue
			current_color = LightColors.RED
			color_sprite.visible = false  # Hide Sprite2D

			# Turn on shield and set gun shader mode to 0
			if player:
				var shield = player.get_node("Shield")  # Adjust the path if needed
				if shield and shield.has_method("toggle_shield"):
					shield.toggle_shield()
					
				var speed_boost_vfx = player.get_node("SpeedBoostVFX")  # Adjust the path if needed
				if speed_boost_vfx:
					speed_boost_vfx.emitting = false
				
				# Set gun shader mode to 0
				var gun = player.get_node("Gun")  # Adjust path as needed
				if gun and gun.material and gun.material is ShaderMaterial:
					gun.material.set_shader_parameter("mode", 0)

		LightColors.RED:
			_remove_buff()  # Remove previous buffs
			_apply_blue_buff()  # Apply the shooting cooldown reduction
			point_light.color = Color(1, 0, 0)  # Red
			self.modulate = Color(1, 0.5, 0.5)  # Light Red
			current_color = LightColors.YELLOW
			color_sprite.visible = false  # Hide Sprite2D
			
			# Turn off shield and set gun shader mode to 1
			if player:
				var shield = player.get_node("Shield")  # Adjust the path if needed
				if shield and shield.has_method("toggle_off"):
					shield.toggle_off()
					
				var speed_boost_vfx = player.get_node("SpeedBoostVFX")  # Adjust the path if needed
				if speed_boost_vfx:
					speed_boost_vfx.emitting = false
				
				# Set gun shader mode to 1
				var gun = player.get_node("Gun")  # Adjust path as needed
				if gun and gun.material and gun.material is ShaderMaterial:
					gun.material.set_shader_parameter("mode", 1)

		LightColors.YELLOW:
			_remove_buff()  # Remove previous buffs
			_apply_yellow_buff()  # Apply yellow buff
			point_light.color = Color(1, 1, 0)  # Yellow
			self.modulate = Color(1, 1, 0.5)  # Light Yellow
			current_color = LightColors.BLUE
			color_sprite.visible = false  # Make Sprite2D visible

			# Turn on VFX and set gun shader mode to 0
			if player:
				var speed_boost_vfx = player.get_node("SpeedBoostVFX")  # Adjust the path if needed
				if speed_boost_vfx:
					speed_boost_vfx.emitting = true

				# Set gun shader mode to 0
				var gun = player.get_node("Gun")  # Adjust path as needed
				if gun and gun.material and gun.material is ShaderMaterial:
					gun.material.set_shader_parameter("mode", 0)

# Apply the yellow buff (increase speed and jump)
func _apply_yellow_buff():
	if player and not yellow_buff_active:
		player.SPEED *= speed_boost
		yellow_buff_active = true
		player.double_jump_enabled = true

# Apply the blue buff (reduce shoot cooldown)
func _apply_blue_buff():
	if player and not blue_buff_active:
		player.shoot_cooldown *= shoot_cooldown_boost
		blue_buff_active = true
		player.is_triple_shot = true

# Remove the buffs and reset player stats
func _remove_buff():
	if player:
		if yellow_buff_active:
			player.SPEED /= speed_boost
			yellow_buff_active = false
			player.double_jump_enabled = false
		
		if blue_buff_active:
			player.shoot_cooldown /= shoot_cooldown_boost
			blue_buff_active = false
			player.is_triple_shot = false

func _ready():

	
	# Assign the player node (replace 'Player' with your actual player node path)
	player = get_node("/root/Game/Player")
	color_sprite.visible = true  # Make Sprite2D visible on ready
	
	if player:
		var gun = player.get_node("Gun")  # Adjust path as needed
		if gun and gun.material and gun.material is ShaderMaterial:
			gun.material.set_shader_parameter("mode", 0)
	
	
			
func _process(delta: float):
	# Update cooldown timer
	if buffswitch_cooldown > 0:
		buffswitch_cooldown -= delta

	if player:
		# Calculate a random flutter position around the player
		var offset = Vector2(randf_range(-flutter_distance, flutter_distance), randf_range(-flutter_distance, flutter_distance))
		var target_position = player.position + offset

		# Move towards the target position with flutter speed using lerp
		position = position.lerp(target_position, flutter_speed * delta)

	# Check for buffswitch input and ensure cooldown has passed
	if Input.is_action_just_pressed("buffswitch") and buffswitch_cooldown <= 0:
		_change_light_color()
		buffswitch_cooldown = buffswitch_delay
		
	# Function to remove any active effects
func remove():
	# Deactivate the shield
	if player:
		var shield = player.get_node("Shield")  # Adjust the path if needed
		if shield and shield.has_method("toggle_off"):
			shield.toggle_off()

		# Reset gun shader mode to 0
		var gun = player.get_node("Gun")  # Adjust the path if needed
		if gun and gun.material and gun.material is ShaderMaterial:
			gun.material.set_shader_parameter("mode", 0)

		# Turn off speed boost VFX
		var speed_boost_vfx = player.get_node("SpeedBoostVFX")  # Adjust the path if needed
		if speed_boost_vfx:
			speed_boost_vfx.emitting = false

	# Remove buffs and reset player stats
	_remove_buff()
	queue_free()
