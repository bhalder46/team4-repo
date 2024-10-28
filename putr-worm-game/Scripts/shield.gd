extends AnimatedSprite2D  # Ensure this script extends AnimatedSprite2D

@onready var area = $Area2D  # Ensure Area2D is a child of this node
@onready var spawn_timer = $SpawnTimer  # Timer node for handling the spawn animation duration
@onready var shield_timer = $ShieldTimer  # Timer for handling the shield disabling duration

# Duration of the spawn animation
var spawn_animation_duration: float = 0.5 # Adjust this based on your animation length
var shield_disable_duration: float = 4.0  # Duration to disable the shield
var shield_active: bool = false  # Track if the shield is currently active
var is_disabled: bool = false  # Variable to disable the script functionality

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set initial state
	self.visible = false  # Set shield visibility to false
	shield_active = false  # Ensure shield is inactive

# Method to start the spawn process
func start_spawn():
	if is_disabled:  # Check if the script is disabled
		return
	
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

# Function triggered when another Area2D enters the area
func _on_Area2D_entered(area: Area2D) -> void:
	if is_disabled:  # Check if the script is disabled
		return
	
	if shield_active:  # Check if the shield is currently active
		return  # If shield is active, ignore further hits

	print_debug("Area entered: ", area.name)  # Debug message to see what area entered

	if area.is_in_group("enemybullet"):
		print_debug("Enemy bullet detected: ", area.name)  # Specific debug for enemy bullets

		# Stop the spawn timer if a bullet collides during the spawn phase
		if spawn_timer.is_stopped() == false:
			spawn_timer.stop()
			print_debug("Spawn timer stopped due to bullet collision.")

		# Play die animation before freeing the shield
		play("die")  # Ensure the die animation exists

		# Queue free the enemy bullet
		area.queue_free()
		print("deleted")
		
		# Disable area monitoring
		area.monitoring = false  # Disable the area detection
		shield_active = true  # Activate the shield state

		# Start the shield disable timer
		shield_timer.start(shield_disable_duration)  # Start the shield timer
		shield_timer.connect("timeout", Callable(self, "_on_shield_timer_timeout"))

# Function triggered when the shield timer times out
func _on_shield_timer_timeout() -> void:
	if is_disabled:  # Check if the script is disabled
		return
	
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
	is_disabled = false
	self.visible = true
	shield_active = false  # Ensure shield is inactive
	area.monitoring = true  # Re-enable area detection if it was disabled
	
	# Start the spawn process
	start_spawn()

# Method to toggle off the shield effect
func toggle_off() -> void:
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
