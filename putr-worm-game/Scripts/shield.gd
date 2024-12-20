extends AnimatedSprite2D  # Ensure this script extends AnimatedSprite2D

@onready var area = $Area2D  # Ensure Area2D is a child of this node
@onready var spawn_timer = $SpawnTimer  # Timer node for handling the spawn animation duration
@onready var shield_timer = $ShieldTimer  # Timer for handling the shield disabling duration

@onready var shieldUI = get_parent().get_node("shieldUI")
@onready var shield_anim: AnimationPlayer = get_parent().get_node("shieldAnim")

var hit_count: int = 0
# Duration of the spawn animation
var spawn_animation_duration: float = 0.5 # Adjust this based on your animation length
var shield_disable_duration: float = 2.5  # Duration to disable the shield
var shield_active: bool = false  # Track if the shield is currently active
var is_disabled: bool = false  # Variable to disable the script functionality

# Called when the node enters the scene tree for the first time.
func _ready():
	shieldUI.visible = false
	# Set initial state
	self.visible = false  # Set shield visibility to false
	shield_active = false  # Ensure shield is inactive

# Method to start the spawn process
func start_spawn():
	if is_disabled:  # Check if the script is disabled
		return
	shieldUI.visible = true
	shield_anim.play("spawnUI")
	
	play("spawn")
	# Start the spawn timer
	spawn_timer.start(spawn_animation_duration)
	
	# Connect the timer's timeout signal to switch to idle
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_animation_finished"))
	
	# Connect the area_entered signal to detect Area2D nodes
	area.connect("area_entered", Callable(self, "_on_Area2D_entered"))

# Function triggered when the spawn animation finishes
func _on_spawn_animation_finished() -> void:
	if is_disabled:  # Check if the script is disabled
		return
	
	play("idle")  # Switch to idle animation
	print_debug("Spawn animation finished.")
	

var time_since_last_bullet: float = 0.0
var bullet_check_active: bool = false

func _on_Area2D_entered(area: Area2D) -> void:
	if is_disabled or shield_active:  # Skip if disabled or shield is active
		return

	if area.is_in_group("enemybullet"):
		print_debug("Enemy bullet detected: ", area.name)
		area.queue_free()  # Remove the bullet
		hit_count += 1  # Increment hit counter
		print_debug("Hit count: ", hit_count)

		# Reset the timer since a new bullet was detected
		time_since_last_bullet = 0.0
		bullet_check_active = true  # Enable bullet tracking

		if hit_count >= 4:  # Trigger logic only after 4 hits
			# Stop the spawn timer if active
			if spawn_timer.is_stopped() == false:
				spawn_timer.stop()
				print_debug("Spawn timer stopped due to bullet collision.")

			# Play die animation and disable monitoring
			play("die")
			shieldUI.play("empty")
			shield_anim.play("deathUI")
			area.monitoring = false
			shield_active = true

			# Start shield disable logic
			shield_timer.start(shield_disable_duration)
			shield_timer.connect("timeout", Callable(self, "_on_shield_timer_timeout"))
			shieldUI.visible = false
			# Reset hit count
			bullet_check_active = false  # Disable tracking once shield logic triggers

func _process(delta: float) -> void:
	if bullet_check_active and hit_count < 4:
		time_since_last_bullet += delta
		if time_since_last_bullet >= 2.0:  # 2 seconds have passed
			print_debug("No bullets detected for 2 seconds. Resetting hit count.")
			
			hit_count = 0
			bullet_check_active = false  # Stop checking
			time_since_last_bullet = 0.0
	
	# Update shield UI based on hit count
	update_shield_ui()

# Function to update the shield UI animation
func update_shield_ui() -> void:
	match hit_count:
		3:
			shieldUI.play("1")
		2:
			shieldUI.play("2")
		1:
			shieldUI.play("3")
		0:
			shieldUI.play("full")
			
# Function triggered when the shield timer times out
func _on_shield_timer_timeout() -> void:
	if is_disabled:  # Check if the script is disabled
		return
	
	shield_anim.play("spawnUI")
	shieldUI.visible = true
	
	hit_count = 0
	# Re-enable area monitoring
	area.monitoring = true  # Re-enable the area detection
	
	# Reset shield active state
	shield_active = false  # Deactivate the shield state

	# Play spawn animation
	play("spawn")
	print_debug("Shield reactivated after timeout.")
	
	# Start a timer to switch to idle animation after the spawn animation duration
	spawn_timer.start(spawn_animation_duration)  # Restart the spawn timer
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_animation_finished"))

# Method to toggle the shield effect as if loading for the first time
func toggle_shield() -> void:
	hit_count = 0
	is_disabled = false
	self.visible = true
	shield_active = false  # Ensure shield is inactive
	area.monitoring = true  # Re-enable area detection if it was disabled
	
	# Start the spawn process
	start_spawn()

# Method to toggle off the shield effect
func toggle_off() -> void:
	shieldUI.visible = false
	shield_anim.play("deathUI")
	is_disabled = true  # Disable the script functionality

	if not shield_active:  # Check if the shield is currently active
		# Play die animation only if shield is active
		play("die")
	
	# Start a timer for 1 second
	var timer = get_tree().create_timer(0.3)
	await timer.timeout  # Wait for the timer to complete

	# Hide shield visibility
	self.visible = false  # Hide the shield sprite

	# Disable the shield
	shield_active = false  # Deactivate the shield state
	
	# Disable area monitoring
	area.monitoring = false  # Disable area detection
	print_debug("Shield toggled off.")
