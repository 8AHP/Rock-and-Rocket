extends Camera2D

var shake_intensity = 0.0
var shake_duration = 0.0
var shake_timer = 0.0
var original_offset: Vector2

func _ready():
	original_offset = offset

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta
		# **CHANGED:** Random shake offset calculation
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		offset = original_offset + shake_offset
		
		# **CHANGED:** Decay shake intensity over time
		shake_intensity = lerp(shake_intensity, 0.0, delta * 5.0)
	else:
		# **CHANGED:** Return to original position when done
		offset = lerp(offset, original_offset, delta * 10.0)

# **NEW:** Trigger screen shake from anywhere
func add_shake(intensity: float, duration: float):
	shake_intensity = max(shake_intensity, intensity)  # Don't override stronger shakes
	shake_duration = duration
	shake_timer = duration
