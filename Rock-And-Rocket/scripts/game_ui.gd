extends CanvasLayer

@onready var score_label: Label = $UIContainer/ScoreDisplay/ScoreLabel
@onready var time_label: Label = $UIContainer/TimeDisplay/TimeLabel
@onready var score_shake: AnimationPlayer = $UIContainer/ScoreDisplay/ScoreShake

# Load custom font
var custom_font = load("res://assests/font/PixelOperator8.ttf")

# Shake animation properties
var shake_intensity: float = 10.0
var shake_duration: float = 0.3

func _ready():
	# **NEW:** Add to UI group FIRST for spawner access
	add_to_group("game_ui")
	print("GameUI added to group 'game_ui'")  # **DEBUG**
	
	# **FIXED:** Check if signals are already connected before connecting
	if not ScoreManager.score_changed.is_connected(_on_score_changed):
		ScoreManager.score_changed.connect(_on_score_changed)
		print("Connected score_changed signal")  # **DEBUG**
	
	if not ScoreManager.combo_changed.is_connected(_on_combo_changed):
		ScoreManager.combo_changed.connect(_on_combo_changed)
		print("Connected combo_changed signal")  # **DEBUG**
	
	ScoreManager.set_ui_controller(self)
	
	# Set up initial display
	setup_ui_styling()
	update_displays()

func _process(delta):
	# Update time display every frame
	time_label.text = "TIME: " + ScoreManager.get_time_text()

func setup_ui_styling():
	# SCORE LABEL STYLING (UPPER LEFT)
	score_label.position = Vector2(50, 50)
	score_label.size = Vector2(300, 60)
	score_label.add_theme_font_size_override("font_size", 32)
	score_label.add_theme_color_override("font_color", Color. CYAN)
	score_label.add_theme_color_override("font_shadow_color", Color. BLACK)
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
	
	# COMBO LABEL STYLING (SAME POSITION AS OLD MULTIPLIER)
	var combo_label = Label.new()
	combo_label.name = "ComboLabel"
	combo_label.position = Vector2(50, 170)
	combo_label.size = Vector2(300, 60)
	combo_label.add_theme_font_override("font", custom_font)
	combo_label.add_theme_font_size_override("font_size", 24)
	combo_label.add_theme_color_override("font_color", Color.ORANGE)
	combo_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	combo_label.add_theme_constant_override("shadow_offset_x", 3)
	combo_label.add_theme_constant_override("shadow_offset_y", 3)
	combo_label.text = ""
	$UIContainer.add_child(combo_label)
	
	var level_alert = Label.new()
	# **FIXED:** Level alert positioned UNDER combo counter
	level_alert.name = "LevelAlert"
	level_alert.position = Vector2(50, 220)  # **HIGHLIGHTED: UNDER COMBO**
	level_alert.size = Vector2(400, 80)  # **HIGHLIGHTED: WIDER FOR BETTER TEXT**
	level_alert.add_theme_font_override("font",load("res://assests/font/PixelOperator8-Bold.ttf"))
	level_alert.add_theme_font_size_override("font_size", 16)  # **HIGHLIGHTED: SMALLER FONT**
	level_alert.add_theme_color_override("font_color", Color.RED)
	level_alert.add_theme_color_override("font_shadow_color", Color. BLACK)
	level_alert. add_theme_constant_override("shadow_offset_x", 3)
	level_alert.add_theme_constant_override("shadow_offset_y", 3)
	level_alert.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT  # **HIGHLIGHTED: LEFT ALIGN**
	level_alert.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_alert.modulate. a = 0.0  # Hidden by default
	$UIContainer. add_child(level_alert)
	print("Level alert label created at position: ", level_alert.position)
	
	# Apply custom font to score label
	score_label.add_theme_font_override("font", custom_font)
	score_label.add_theme_font_size_override("font_size", 36)

func update_displays():
	score_label.text = "SCORE: " + ScoreManager.get_score_text()

func _on_score_changed(new_score: int, points_added: int):
	update_displays()
	trigger_score_shake()
	show_points_popup(points_added)

func _on_combo_changed(combo_count: int, multiplier: float):
	var combo_label = $UIContainer/ComboLabel
	if combo_label:
		if combo_count > 1:
			combo_label.text = "COMBO x" + str(combo_count) + "\nMULTIPLIER x" + str(multiplier). pad_decimals(1)
			
			# Combo visual effects
			var pulse_tween = create_tween()
			pulse_tween.tween_property(combo_label, "scale", Vector2(1.3, 1.3), 0.1)
			pulse_tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.2)
			
			# Color pulse effect
			var color_tween = create_tween()
			color_tween.tween_property(combo_label, "modulate", Color.RED, 0.1)
			color_tween.tween_property(combo_label, "modulate", Color.ORANGE, 0.2)
		else:
			combo_label. text = ""

func show_level_up_alert(level: int):
	var level_alert = $UIContainer/LevelAlert
	if level_alert:
		level_alert. text = "LEVEL " + str(level) + "!"
		
		# **RAPID FLASHING ANIMATION**
		var flash_tween = create_tween()
		flash_tween.set_loops(6)  # **HIGHLIGHTED: X RAPID FLASHES**
		
		# **FAST FLASH CYCLE:**
		flash_tween.tween_property(level_alert, "modulate:a", 1.0, 0.1)   # **APPEAR**
		flash_tween.tween_property(level_alert, "modulate", Color. RED, 0.05)    # **RED**
		flash_tween. tween_property(level_alert, "modulate", Color. YELLOW, 0.05)  # **YELLOW**
		flash_tween.tween_property(level_alert, "modulate:a", 0.2, 0.1)   # **DIM**
		
		# **FINAL FADE OUT - USING TIMER INSTEAD OF TWEEN_DELAY**
		await flash_tween.finished  # **HIGHLIGHTED: WAIT FOR FLASHING TO COMPLETE**
		
		var fade_tween = create_tween()
		fade_tween. tween_property(level_alert, "modulate:a", 0.0, 0.5)


# SCORE SHAKE ANIMATION (UNCHANGED)
func trigger_score_shake():
	var tween = create_tween()
	tween.set_loops(3)
	
	tween.tween_method(
		func(offset): score_label.position.x = 50 + offset,
		0.0, shake_intensity, shake_duration / 6
	)
	tween.tween_method(
		func(offset): score_label.position.x = 50 + offset,
		shake_intensity, -shake_intensity, shake_duration / 3
	)
	tween. tween_method(
		func(offset): score_label.position.x = 50 + offset,
		-shake_intensity, 0.0, shake_duration / 6
	)
	
	var scale_tween = create_tween()
	scale_tween. tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
	scale_tween. tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.2)

# FLOATING POINTS DISPLAY (UNCHANGED)
func show_points_popup(points: int):
	var popup_label = Label.new()
	popup_label.text = "+" + str(points)
	popup_label.position = score_label.position + Vector2(250, 0)
	popup_label.add_theme_font_override("font", custom_font)
	popup_label.add_theme_font_size_override("font_size", 28)
	popup_label.add_theme_color_override("font_color", Color.GREEN)
	popup_label.modulate.a = 1.0
	
	$UIContainer.add_child(popup_label)
	
	var popup_tween = create_tween()
	popup_tween.parallel(). tween_property(popup_label, "position", popup_label.position + Vector2(50, -50), 1.0)
	popup_tween.parallel().tween_property(popup_label, "modulate:a", 0.0, 1.0)
	popup_tween.tween_callback(popup_label.queue_free)
