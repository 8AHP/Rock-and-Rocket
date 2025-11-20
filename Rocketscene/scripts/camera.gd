extends Camera2D

@export var follow_speed: float = 8.0
@export var look_ahead_distance: float = 40.0
@export var max_zoom_out: float = 1.0
@export var min_zoom_in: float = 0.95

var player: Node2D
var target_zoom: float = 1.0

# Screen shake variables
var shake_intensity = 0.0
var shake_timer = 0.0

func _ready():
	player = get_parent()
	make_current()

func _process(delta):
	# Zoom logic (WORKING)
	var player_velocity = 0.0
	if player.has_method("get_velocity"):
		player_velocity = player.get_velocity()
	
	var speed_factor = abs(player_velocity) / 400.0
	target_zoom = lerp(min_zoom_in, max_zoom_out, speed_factor)
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), delta * 2.0)
	
	# **FIXED:** Look-ahead with proper direction access
	var look_ahead = Vector2.ZERO
	if player.has_method("get_velocity") and abs(player_velocity) > 50:
		look_ahead = player.direction * look_ahead_distance * (abs(player_velocity) / 400.0)
	
	# Screen shake + look-ahead combined
	var target_offset = look_ahead
	if shake_timer > 0:
		shake_timer -= delta
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		target_offset += shake_offset
		shake_intensity = lerp(shake_intensity, 0.0, delta * 5.0)
	
	offset = offset.lerp(target_offset, delta * follow_speed)
	
	# **CHANGED:** Inverted parallax background synchronization
	var parallax_bg = get_tree().get_first_node_in_group("starfield_bg")
	if parallax_bg:
		parallax_bg.scroll_offset = -global_position  # **HIGHLIGHTED: NEGATIVE SIGN ADDED**

func add_shake(intensity: float, duration: float):
	shake_intensity = max(shake_intensity, intensity)
	shake_timer = duration
