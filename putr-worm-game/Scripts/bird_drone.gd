extends AnimatedSprite2D

# Variable to hold the player reference
var player: CharacterBody2D
var flutter_distance: float = 10.0
var flutter_speed: float = 1.0

# Color states
enum LightColors { BLUE, RED, YELLOW }
var current_color: LightColors = LightColors.BLUE

# Reference to the PointLight2D node
@onready var point_light: PointLight2D = $PointLight2D

# Cooldown timer for buffswitch
var buffswitch_cooldown: float = 0.0
var buffswitch_delay: float = 1.0  # 1 second delay

# Speed, jump, and shoot buffs
var speed_boost: float = 1.2  # 20% speed increase
var jump_boost: float = 1.1  # 10% jump height increase
var shoot_cooldown_boost: float = 0.46  # 20% reduction in shoot cooldown

# Track if buffs are active
var yellow_buff_active: bool = false
var blue_buff_active: bool = false

# Function to change the point light color and apply/remove buffs
func _change_light_color():
	match current_color:
		LightColors.BLUE:
			_remove_buff()  # Remove previous buffs
			_apply_blue_buff()  # Apply blue buff
			point_light.color = Color(0, 0, 1)  # Blue
			self.modulate = Color(0.5, 0.5, 1)  # Light Blue
			current_color = LightColors.RED
		LightColors.RED:
			_remove_buff()  # Remove previous buffs
			point_light.color = Color(1, 0, 0)  # Red
			self.modulate = Color(1, 0.5, 0.5)  # Light Red
			current_color = LightColors.YELLOW
			
			# Call the toggle_shield() method
			if player:
				var shield = player.get_node("Shield")  # Adjust the path if needed
				if shield and shield.has_method("toggle_shield"):
					shield.toggle_shield()
					
		LightColors.YELLOW:
			_remove_buff()  # Remove previous buffs
			_apply_yellow_buff()  # Apply yellow buff
			point_light.color = Color(1, 1, 0)  # Yellow
			self.modulate = Color(1, 1, 0.5)  # Light Yellow
			current_color = LightColors.BLUE
			
			# Call the toggle_off() method
			if player:
				var shield = player.get_node("Shield")  # Adjust the path if needed
				if shield and shield.has_method("toggle_off"):
					shield.toggle_off()

# Apply the yellow buff (increase speed and jump)
func _apply_yellow_buff():
	if player and not yellow_buff_active:
		player.SPEED *= speed_boost
		player.JUMP_VELOCITY *= jump_boost
		yellow_buff_active = true

# Apply the blue buff (reduce shoot cooldown)
func _apply_blue_buff():
	if player and not blue_buff_active:
		player.shoot_cooldown *= shoot_cooldown_boost
		blue_buff_active = true

# Remove the buffs and reset player stats
func _remove_buff():
	if player:
		if yellow_buff_active:
			player.SPEED /= speed_boost
			player.JUMP_VELOCITY /= jump_boost
			yellow_buff_active = false
		
		if blue_buff_active:
			player.shoot_cooldown /= shoot_cooldown_boost
			blue_buff_active = false

func _ready():
	# Assign the player node (replace 'Player' with your actual player node path)
	player = get_node("/root/Game/Player")

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
		buffswitch_cooldown = buffswitch_delay  # Set cooldown
