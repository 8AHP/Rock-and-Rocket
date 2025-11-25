extends ParallaxBackground

var max_scroll_distance = 2000.0  # **NEW:** Maximum scroll before reset

func _ready():
	add_to_group("starfield_bg")

# **NEW:** Prevent infinite scrolling issues
func _process(delta):
	# **NEW:** Reset scroll offset if player goes too far
	if abs(scroll_offset.x) > max_scroll_distance or abs(scroll_offset.y) > max_scroll_distance:
		scroll_offset = Vector2.ZERO  # **HIGHLIGHTED: BOUNDARY RESET**
		print("Background reset to prevent edge detection")  # **DEBUG**
