extends Node

# Screenshake parameters
@export var shake_intensity: float = 14.0  # Intensity of the short shake
@export var shake_duration: float = 0.2  # Duration of the short shake

# Long screenshake parameters
@export var long_shake_intensity: float = 9.0  # Intensity of the long shake
@export var long_shake_duration: float = 8.0  # Duration of the long shake

var shake_timer: float = 0.0
var is_shaking: bool = false
var shake_intensity_active: float = 0.0
var original_offsets: Dictionary = {}  # Store original offsets for each camera

func _process(delta: float) -> void:
	if is_shaking:
		shake_timer -= delta
		if shake_timer <= 0.0:
			is_shaking = false
			shake_intensity_active = 0.0
			_reset_offsets()
		else:
			_apply_shake_to_all_cameras()

# Call this method to trigger a short screenshake effect
func screenshake() -> void:
	is_shaking = true
	shake_timer = shake_duration
	shake_intensity_active = shake_intensity
	_store_original_offsets()

# Call this method to trigger a longer, more intense screenshake effect
func screenshake_long() -> void:
	is_shaking = true
	shake_timer = long_shake_duration
	shake_intensity_active = long_shake_intensity
	_store_original_offsets()

# Call this method to stop the screenshake early
func screenshake_stop() -> void:
	is_shaking = false
	shake_intensity_active = 0.0
	_reset_offsets()

func _apply_shake_to_all_cameras() -> void:
	var shake_offset = Vector2(
		randf_range(-shake_intensity_active, shake_intensity_active),
		randf_range(-shake_intensity_active, shake_intensity_active)
	)
	for camera in _get_all_cameras():
		if original_offsets.has(camera):
			camera.offset = original_offsets[camera] + shake_offset

func _store_original_offsets() -> void:
	original_offsets.clear()
	for camera in _get_all_cameras():
		original_offsets[camera] = camera.offset

func _reset_offsets() -> void:
	for camera in original_offsets.keys():
		if camera in _get_all_cameras():  # Ensure camera is still valid
			camera.offset = original_offsets[camera]
	original_offsets.clear()

func _get_all_cameras() -> Array:
	var cameras = []
	var tree = get_tree()
	var root = tree.root
	_find_cameras_recursive(root, cameras)
	return cameras

func _find_cameras_recursive(node: Node, cameras: Array) -> void:
	if node is Camera2D:
		cameras.append(node)
	for child in node.get_children():
		_find_cameras_recursive(child, cameras)
