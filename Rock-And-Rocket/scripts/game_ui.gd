extends CanvasLayer

@onready var score_label: Label = $UIContainer/ScoreDisplay/ScoreLabel
@onready var time_label: Label = $UIContainer/TimeDisplay/TimeLabel
@onready var multiplier_label: Label = $UIContainer/MultiplierDisplay/MultiplierLabel
@onready var score_shake: AnimationPlayer = $UIContainer/ScoreDisplay/ScoreShake

# Load custom font
var custom_font = load("res://assests/font/PixelOperator8.ttf")

# Shake animation properties
var shake_intensity: float = 10.0
var shake_duration: float = 0.3

func _ready():
	# Connect to ScoreManager signals
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.multiplier_changed.connect(_on_multiplier_changed)
	ScoreManager.set_ui_controller(self)
	
	# Set up initial display
	setup_ui_styling()
	update_displays()

func _process(delta):
	# Update time display every frame
	time_label.text = "TIME: " + ScoreManager.get_time_text()

func setup_ui_styling():
	# SCORE LABEL STYLING (UPPER LEFT)
	score_label.position = Vector2(50, 50)  # TOP-LEFT POSITIONING
	score_label.size = Vector2(300, 60)
	score_label.add_theme_font_size_override("font_size", 32)
	score_label.add_theme_color_override("font_color", Color.CYAN)
	score_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	score_label.add_theme_constant_override("shadow_offset_x", 3)
	score_label.add_theme_constant_override("shadow_offset_y", 3)
	
	# TIME LABEL STYLING (UPPER LEFT, BELOW SCORE)
	time_label.position = Vector2(50, 120)
	time_label.size = Vector2(200, 40)
	time_label.add_theme_font_size_override("font_size", 24)
	time_label.add_theme_color_override("font_color", Color.WHITE)
	time_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	time_label.add_theme_constant_override("shadow_offset_x", 2)
	time_label.add_theme_constant_override("shadow_offset_y", 2)
	
	# MULTIPLIER LABEL STYLING (UPPER LEFT, BELOW TIME)
	multiplier_label.position = Vector2(50, 170)
	multiplier_label.size = Vector2(200, 40)
	multiplier_label.add_theme_font_size_override("font_size", 20)
	multiplier_label.add_theme_color_override("font_color", Color.YELLOW)
	multiplier_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	multiplier_label.add_theme_constant_override("shadow_offset_x", 2)
	multiplier_label.add_theme_constant_override("shadow_offset_y", 2)

	
	# Apply to score label
	score_label.add_theme_font_override("font", custom_font)
	score_label.add_theme_font_size_override("font_size", 36)

func update_displays():
	score_label.text = "SCORE: " + ScoreManager.get_score_text()
	multiplier_label.text = "x" + str(ScoreManager.score_multiplier)

func _on_score_changed(new_score: int, points_added: int):
	# Update score display
	update_displays()
	
	# Trigger shake animation
	trigger_score_shake()
	
	# Optional: Show floating points text
	show_points_popup(points_added)

func _on_multiplier_changed(new_multiplier: int):
	update_displays()
	# Optional: Flash multiplier display
	flash_multiplier()

# SCORE SHAKE ANIMATION (SIGNATURE FEATURE)
func trigger_score_shake():
	var tween = create_tween()
	tween.set_loops(3)  # Shake 3 times
	
	# Shake horizontally
	tween.tween_method(
		func(offset): score_label.position.x = 50 + offset,
		0.0, shake_intensity, shake_duration / 6
	)
	tween.tween_method(
		func(offset): score_label.position.x = 50 + offset,
		shake_intensity, -shake_intensity, shake_duration / 3
	)
	tween.tween_method(
		func(offset): score_label.position.x = 50 + offset,
		-shake_intensity, 0.0, shake_duration / 6
	)
	
	# Scale pulse effect
	var scale_tween = create_tween()
	scale_tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
	scale_tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.2)

# FLOATING POINTS DISPLAY (OPTIONAL POLISH)
func show_points_popup(points: int):
	var popup_label = Label.new()
	popup_label.text = "+" + str(points)
	popup_label.position = score_label.position + Vector2(250, 0)
	popup_label.add_theme_font_override("font", custom_font)
	popup_label.add_theme_font_size_override("font_size", 28)
	popup_label.add_theme_color_override("font_color", Color.GREEN)
	popup_label.modulate.a = 1.0
	
	$UIContainer.add_child(popup_label)
	
	# Animate popup
	var popup_tween = create_tween()
	popup_tween.parallel().tween_property(popup_label, "position", popup_label.position + Vector2(50, -50), 1.0)
	popup_tween.parallel().tween_property(popup_label, "modulate:a", 0.0, 1.0)
	popup_tween.tween_callback(popup_label.queue_free)

func flash_multiplier():
	var flash_tween = create_tween()
	flash_tween.tween_property(multiplier_label, "modulate", Color.RED, 0.1)
	flash_tween.tween_property(multiplier_label, "modulate", Color.YELLOW, 0.1)
