extends RigidBody2D

@export var blue_attack_scene_right: PackedScene  # Make sure the scene is exported and set in the editor
@export var blue_attack_scene_left: PackedScene  # Make sure the scene is exported and set in the editor
@export var red_boss_trap_scene: PackedScene
@export var fly_boss_scene: PackedScene  # Export FlyBoss scene for the editor
@export var yellowBossRIGHT_scene: PackedScene
@export var yellowBossUP_scene: PackedScene
@export var yellowBossLEFT_scene: PackedScene

@export var bossEnding: PackedScene

@onready var markers = [
	$bugShield1,
	$bugShield2,
	$bugShield3,
	$bugShield4
]  

@onready var pause_menu = get_parent().get_node("PauseLayer/Pause_Menu")
@onready var hitBox_regular = $hitBox
@onready var heal_VFX = $healVFX

@onready var bossLaugh = $bossLaugh
@onready var birdDeathSound = $birdDeathSound
@onready var bossMusic = $bossMusic
@onready var birdLight = $birdLight

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite_head = $Head
@onready var animated_sprite_vine = $Vines
@onready var animated_sprite_tv = $TV
@onready var tv_area = animated_sprite_tv.get_node("tvCrit")

@onready var health_bar = $BossBarCanvas/BossHealthBar
@onready var point_light = $PointLight2D  

@onready var glitch_rect = $glitchRect 

@export var mob_projectile_scene: PackedScene
@export var attack_cooldown: float = 1.0

@onready var shield_sprite = $Shield  # Reference to the Shield AnimatedSprite2D
@onready var shield_area = shield_sprite.get_node("AreaShield")

# Variables for pulse logic
var pulse_duration: float = 0.4  # Total pulse time (seconds)
var pulse_energy_start: float = 60
var pulse_energy_end: float = 100
var pulse_timer: float = 0.0  # Tracks elapsed time during the pulse
var is_pulsing: bool = false

var can_attack: bool = true
var player_in_range: bool = false
var is_idle_active: bool = false  # New variable to check if idle is active
var is_red_method_active: bool = false  # New flag for red method activation


var max_health: float = 1500.0
var current_health: float = max_health
var damage_taken_per_hit: float = 17.0
var is_hurt: bool = false
var hurt_animation_time: float = 0.2
var is_dying: bool = false


func _ready():
	shield_area.monitoring = true  
	shield_area.monitorable = true
	if not player:
		print("Player not found")
	
	player.disable_movement = true
	player.disable_shooting = true
	
	await get_tree().create_timer(2.0).timeout
	intro()
	
func setup_health_bar():
	health_bar.value = 0
	health_bar.max_value = max_health
	health_bar.show()
	fill_health_bar()
	$healthRise.play()

func fill_health_bar():
	var duration = 4.0  # Duration of the fill animation in seconds
	var increment = max_health / (duration * 200)  # Increment per frame (assuming 60 FPS)
	while health_bar.value < current_health:
		health_bar.value += increment
		health_bar.value = min(health_bar.value, current_health)  # Avoid overshooting
		await get_tree().process_frame  # Wait for the next frame

@onready var bird_bullet = $BirdBullet
@onready var bird = $Bird
@onready var bird_death = $birdDeath

var target_position : Vector2
var speed : float = 200.0  # Set the speed (pixels per second)
var is_moving : bool = false  # Flag to control movement state

func intro():
	animated_sprite_head.play("headDown")
	await get_tree().create_timer(2.0).timeout
	animated_sprite_head.play("headShootIntro")
	await get_tree().create_timer(0.3).timeout
	$shootball.play()
	
	target_position = bird_bullet.global_position + Vector2(0, 147)
	is_moving = true
	await get_tree().create_timer(2.5).timeout
	animated_sprite_head.play("headUpIntro")
	
	await get_tree().create_timer(1.0).timeout
	
	var start_energy = point_light.energy
	var end_energy = 100.0
	var duration = 0.5
	var timer = 0.0
	$birdLight.play()
	while timer < duration:
		point_light.energy = lerp(start_energy, end_energy, timer / duration)
		timer += get_process_delta_time() 
		await get_tree().create_timer(0.0001).timeout
	point_light.energy = end_energy
	
	await get_tree().create_timer(2.0).timeout
	
	animated_sprite_head.play("headLaughIntro")
	$bossLaugh.play()
	CameraShakeGlobalSingleton.screenshake_long()
	await get_tree().create_timer(7.5).timeout
	CameraShakeGlobalSingleton.screenshake_stop()
	animated_sprite_head.play("headUpIntro")
	await get_tree().create_timer(1.0).timeout
	
	setup_health_bar()
	
	await get_tree().create_timer(1.0).timeout
	animated_sprite_vine.play("idleVines")
	$bossMusic.play()
	shield_area.monitoring = false  
	shield_area.monitorable = false 
	animated_sprite_head.play("headIdle")
	await get_tree().create_timer(1.1).timeout
	rapid_color_switch()
	await get_tree().create_timer(1.0).timeout
	player.disable_movement = false
	player.disable_shooting = false
	idle()


var switching = false
var elapsed_time = 0.0
var switch_interval = 0.1
var total_duration = 1.0
var color_index = 0

func _process(delta: float):
	if is_moving:
		# Calculate the direction to move in
		var direction = (target_position - bird_bullet.global_position).normalized()
		
		# Move the bird_bullet at constant speed
		bird_bullet.global_position += direction * speed * delta
		
		# Check if the bird_bullet has reached or passed the target position
		if bird_bullet.global_position.distance_to(target_position) <= speed * delta:
			# Once the target is reached, stop moving and queue free
			is_moving = false
			bird_bullet.queue_free()
			bird.queue_free()
			bird_death.play("birdDeath")
			$birdDeathSound.play()
	
	
	if is_pulsing:
		pulse_timer += delta

		if pulse_timer <= pulse_duration / 2:
			# First half of the pulse: increase energy
			var t = pulse_timer / (pulse_duration / 2)
			point_light.energy = lerp(pulse_energy_start, pulse_energy_end, t)
		elif pulse_timer <= pulse_duration:
			# Second half of the pulse: decrease energy
			var t = (pulse_timer - pulse_duration / 2) / (pulse_duration / 2)
			point_light.energy = lerp(pulse_energy_end, pulse_energy_start, t)
		else:
			# End the pulse
			point_light.energy = pulse_energy_start
			is_pulsing = false
			
	if switching:
		elapsed_time += delta
		if elapsed_time >= total_duration:
			switching = false
			return
		
		# Switch color at intervals
		if int(elapsed_time / switch_interval) > int((elapsed_time - delta) / switch_interval):
			point_light.color = colors[color_index]
			color_index = (color_index + 1) % colors.size()

func rapid_color_switch():
	if switching:
		return # Prevent multiple triggers
	switching = true
	elapsed_time = 0.0
	color_index = 0
	
func _physics_process(_delta):
	if is_dying:
		return
		
	if player_in_range and can_attack and is_instance_valid(player) and is_idle_active:
		# Modify shooting behavior based on red method
		if is_red_method_active:
			shoot_at_player_red()  # Use red method's shooting behavior
		else:
			shoot_at_player()  # Default idle shooting behavior

func pulse_light():
	if not point_light:
		return

	# Initialize pulse variables
	pulse_timer = 0.0
	is_pulsing = true

func shoot_at_player():
	if can_attack and player:
		$shootball.play()
		animated_sprite_head.play("headShoot")
		can_attack = false

		var spawn_position = global_position - Vector2(0, -20)  # Adjusted spawn position
		
		var projectile = mob_projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = spawn_position
		
		# Adjusted direction calculation
		var direction = (player.global_position - spawn_position).normalized()
		projectile.set_direction(direction)

		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true


func shoot_at_player_red():
	if can_attack and player:
		$shootball.play()
		animated_sprite_head.play("headShoot")
		can_attack = false

		var spawn_position = global_position - Vector2(0, -20)  # Adjusted spawn position
		var direction = (player.global_position - spawn_position).normalized()

		# Bullet 1: Straight
		var projectile_straight = mob_projectile_scene.instantiate()
		get_parent().add_child(projectile_straight)
		projectile_straight.global_position = spawn_position
		projectile_straight.set_direction(direction)

		# Bullet 2: Slightly to the left
		var direction_left = direction.rotated(-0.04)  # Rotate left slightly
		var projectile_left = mob_projectile_scene.instantiate()
		get_parent().add_child(projectile_left)
		projectile_left.global_position = spawn_position
		projectile_left.set_direction(direction_left)

		# Bullet 3: Slightly to the right
		var direction_right = direction.rotated(0.04)  # Rotate right slightly
		var projectile_right = mob_projectile_scene.instantiate()
		get_parent().add_child(projectile_right)
		projectile_right.global_position = spawn_position
		projectile_right.set_direction(direction_right)

		# After shooting, wait for the red method's cooldown to continue shooting
		await get_tree().create_timer(0.5).timeout  # Red method has a faster attack cooldown
		can_attack = true

func take_damage():
	if shield_area.monitoring:
		return
		
	if is_dying:
		return
		
	current_health -= damage_taken_per_hit
	health_bar.value = current_health
	
	# Visual feedback - red flash
	animated_sprite_head.modulate = Color(1, 0.3, 0.3)  # Red tint
	animated_sprite_tv.modulate = Color(1, 0.3, 0.3)  # Red tint
	await get_tree().create_timer(hurt_animation_time).timeout
	animated_sprite_head.modulate = Color(1, 1, 1)  # Reset tint
	animated_sprite_tv.modulate = Color(1, 1, 1)  # Reset tint
	
	if current_health <= 0:
		die()

func heal():
	$heal.play()
	heal_VFX.emitting = true

	if is_dying:
		return  # Prevent healing if the boss is already dying

	current_health += 90  # Heal the boss by 90
	if current_health > max_health:
		current_health = max_health  # Ensure health doesn't exceed the maximum value

	health_bar.value = current_health  # Update the health bar
	print("Boss healed! Current health: ", current_health)

	# Create a new StyleBoxFlat and set it as an override for the fill
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 1, 0)  # Green for healing

	# Apply the new style to the fill using theme_override_styles
	health_bar.set("theme_override_styles/fill", style_box)

	# Wait for 0.5 seconds before resetting
	await get_tree().create_timer(0.2).timeout

	# Reset the fill color to white
	style_box.bg_color = Color(1, 1, 1)  # White for default
	health_bar.set("theme_override_styles/fill", style_box)
	print("Fill color reset to white.")



func die():
	print("death")
	is_dying = true
	health_bar.hide()

	# Ensure all bossAttack nodes in the scene tree are freed
	for node in get_tree().get_nodes_in_group("bossAttack"):
		if node.is_inside_tree():
			node.queue_free()
	
	var bossEnd = bossEnding.instantiate()
	get_parent().add_child(bossEnd)
	
	
	player.disable_movement = true
	player.disable_shooting = true
	
	queue_free()



func _on_detection_area_body_entered(body):
	if body.is_in_group("players"):
		player_in_range = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("players"):
		player_in_range = false

func _on_area_entered(area):
	if area.is_in_group("bullets"):
		take_damage()
		area.queue_free()



# Methods for color-based behavior
func redAttack():
	animated_sprite_head.play("headIdle")
	print("Red attack method is active")
	is_red_method_active = true  # Set the red attack method active flag

	# Instantiate traps at the red trap positions
	if red_boss_trap_scene:
		var red_trap1 = red_boss_trap_scene.instantiate()
		red_trap1.global_position = $redTrap1.global_position  # Assuming $redTrap1 is the node reference
		get_parent().add_child(red_trap1)


		var red_trap2 = red_boss_trap_scene.instantiate()
		red_trap2.global_position = $redTrap2.global_position  # Assuming $redTrap2 is the node reference
		get_parent().add_child(red_trap2)
		
		var red_trap3 = red_boss_trap_scene.instantiate()
		red_trap3.global_position = $redTrap3.global_position  # Assuming $redTrap2 is the node reference
		get_parent().add_child(red_trap3)
		
		var red_trap4 = red_boss_trap_scene.instantiate()
		red_trap4.global_position = $redTrap4.global_position  # Assuming $redTrap2 is the node reference
		get_parent().add_child(red_trap4)


	# Stop idle behavior during red attack
	is_idle_active = false

	# Keep shooting for the duration of red attack
	var red_attack_duration = 12.0  # Duration of red attack
	var elapsed_time = 0.0
	
	await get_tree().create_timer(1.5).timeout
	while elapsed_time < red_attack_duration:
		shoot_at_player_red()  # Keep shooting
		await get_tree().create_timer(1.0).timeout  # Interval between shots
		elapsed_time += 1.0

	# Transition to idle after the red attack ends
	idle()  # Transition to the idle method
	is_red_method_active = false  # Reset the red method state

func blueShield():
	print("Blue shield method is active")
	animated_sprite_head.play("headIdle")
	# Activate the shield
	shield_sprite.play("activate")  # Play the shield activation animation
	$shieldOn.play()
	shield_area.monitoring = true  # Enable the Area2D for detection
	shield_area.monitorable = true  # Enable the Area2D for detection
	await get_tree().create_timer(1.2).timeout
	
	shield_sprite.play("idle")

	# Instantiate blueAttack based on marker index
	for i in range(markers.size()):
		var marker = markers[i]
		if marker:
			var blue_attack_instance
			if i == 2 or i == 3:  # Markers 3 and 4
				blue_attack_instance = blue_attack_scene_right.instantiate()
			else:  # Markers 1 and 2
				blue_attack_instance = blue_attack_scene_left.instantiate()
			blue_attack_instance.global_position = marker.global_position
			get_parent().add_child(blue_attack_instance)

	# Wait for the duration of the shield effect
	await get_tree().create_timer(10.0).timeout  # Shield active for 10 seconds

	# Deactivate the shield
	shield_sprite.play("deactivate")  # Play the shield deactivation animation
	$shieldOff.play()

	shield_area.monitoring = false  # Disable the Area2D for detection
	shield_area.monitorable = false  # Enable the Area2D for detection
	idle()  # Transition to the idle method



func yellowMovement():
	print("Yellow method is active")
		# Make glitch_rect visible for 0.5 seconds
	glitch_rect.visible = true
	$static.play()
	
	hitBox_regular.monitoring = false
	hitBox_regular.monitorable = false
	tv_area.monitoring = true
	tv_area.monitorable = true
	
	animated_sprite_head.play("yellowDisappear")
	await get_tree().create_timer(0.3).timeout
	glitch_rect.visible = false
	$static.stop()

	# Arrays of emitters, markers, and scenes
	var emitters = [$yellowVFX1, $yellowVFX2, $yellowVFX3, $yellowVFX4]
	var heads = [$yellowHead1, $yellowHead2, $yellowHead3, $yellowHead4]
	var scenes = [yellowBossRIGHT_scene, yellowBossUP_scene, yellowBossUP_scene, yellowBossLEFT_scene]

	# Shuffle indices to ensure unique random order
	var indices = [0, 1, 2, 3]
	indices.shuffle()

	for i in indices:
		var emitter = emitters[i]
		var head = heads[i]
		var scene = scenes[i]

	# Activate the emitter
		emitter.emitting = true

		var elapsed_time = 0.0
		var blip_interval = 0.1  # Adjust interval as needed

	# Play yellowBlip rapidly for 2.5 seconds
		while elapsed_time < 2.5:
			$yellowBlip.play()
			await get_tree().create_timer(blip_interval).timeout
			elapsed_time += blip_interval

	# Ensure total time is 2.5 seconds
		if elapsed_time < 2.5:
			await get_tree().create_timer(2.5 - elapsed_time).timeout


		# Instantiate the corresponding boss scene at the marker
		if scene:
			var instance = scene.instantiate()
			instance.global_position = head.global_position
			$yellowSpawn.pitch_scale = randf_range(0.70, 1.0)
			$yellowSpawn.play()
			get_parent().add_child(instance)

		# Deactivate the emitter
		emitter.emitting = false
		await get_tree().create_timer(1.0).timeout
		
	await get_tree().create_timer(1.5).timeout
	glitch_rect.visible = true
	$static.play()
	await get_tree().create_timer(.3).timeout
	glitch_rect.visible = false
	$static.stop()
	
	hitBox_regular.monitoring = true
	hitBox_regular.monitorable = true
	tv_area.monitoring = false
	tv_area.monitorable = false

	idle()

func _on_tv_crit_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets"):
		take_damage()
		take_damage()
		take_damage()
		area.queue_free()

func idle():
	pulse_light()
	point_light.color = Color(1, 1, 1)
	animated_sprite_head.play("headIdle")
	await get_tree().create_timer(1.5).timeout
	is_idle_active = true
	print("Idle method is active")


	# Instantiate FlyBoss at bugShield points
	if true:
		var fly_boss1 = fly_boss_scene.instantiate()  # Instantiate the FlyBoss scene
		fly_boss1.global_position = $flySpawn1.global_position  # Set the position at bugShield1
		get_parent().add_child(fly_boss1)  # Add the FlyBoss instance to the scene

		var fly_boss2 = fly_boss_scene.instantiate()  # Instantiate the FlyBoss scene
		fly_boss2.global_position = $flySpawn2.global_position  # Set the position at bugShield4
		get_parent().add_child(fly_boss2)  # Add the FlyBoss instance to the scene

	await get_tree().create_timer(5.0).timeout  # Wait for 12 seconds
	stop_idle()  # Reset the idle flag
	colorSwitch()  # Call colorSwitch again


func stop_idle():
	is_idle_active = false  # Reset the flag when idle is no longer active

# Color switching variables
var colors = [Color(1, 0, 0), Color(1, 1, 0), Color(0, 0, 1)]  # Red, Yellow, Blue
var restricted_color = null
var color_timer = null
var current_color_sequence = []  # To track the current sequence of colors
var is_first_color_switch = true  # Track if it's the first colorSwitch call

func colorSwitch():
	color_timer = Timer.new()
	color_timer.wait_time = 0.5  # Switch color every 0.5 seconds
	color_timer.one_shot = false
	color_timer.autostart = true
	add_child(color_timer)

	color_timer.connect("timeout", Callable(self, "_on_switch_color"))
	
	await get_tree().create_timer(randf_range(3.0, 4.0)).timeout  # Run for 5 seconds

	color_timer.stop()
	remove_child(color_timer)
	color_timer.queue_free()

	# At the end, call the final color's method
	if current_color_sequence.size() > 0:
		var final_color = current_color_sequence[current_color_sequence.size() - 1]
		restricted_color = final_color  # Set the restricted color
		call_color_method(final_color)

	# After the first color switch cycle, reset the flag for next colorSwitch calls
	is_first_color_switch = false


# Variable to track the last used color in the current switching cycle
var last_used_color = null

func _on_switch_color():
	$switch.play()
	pulse_light()
	animated_sprite_head.play("headLaugh")

	# Filter the colors to exclude the restricted color
	var available_colors = []
	for c in colors:
		if c != restricted_color:
			available_colors.append(c)

	# If it's the first time colorSwitch is called, include all three colors
	var new_color = null
	if is_first_color_switch:
		# Ensure that the new color is not the same as the last used color
		var available_non_repeating_colors = []
		for color in available_colors:
			if color != last_used_color:
				available_non_repeating_colors.append(color)
		
		# Select a random color from the available non-repeating colors
		new_color = available_non_repeating_colors[randi() % available_non_repeating_colors.size()]
		
		# Update the last used color
		last_used_color = new_color
	else:
		# At this point, available_colors should have exactly two colors to alternate between
		# Ensure the new color alternates between the available colors
		if last_used_color == available_colors[0]:
			new_color = available_colors[1]
			last_used_color = new_color
		else:
			new_color = available_colors[0]
			last_used_color = new_color

	# Add the new color to the sequence
	current_color_sequence.append(new_color)
	point_light.color = new_color


# Function to call the respective method based on the final color
func call_color_method(color: Color):
	await get_tree().create_timer(1.5).timeout
	if color == colors[0]:  # Red
		redAttack()
	elif color == colors[1]:  # Yellow
		yellowMovement()
	elif color == colors[2]:  # Blue
		blueShield()
