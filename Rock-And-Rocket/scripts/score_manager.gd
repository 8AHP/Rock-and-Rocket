extends Node

# Score tracking variables
var current_score: int = 0
var blocks_destroyed: int = 0
var time_survived: float = 0.0

# **REMOVED:** score_multiplier (was time-based)
# **REMOVED:** multiplier_increase_interval (was 30 seconds)

# Score values
var block_destroy_points: int = 100
var survival_bonus_per_second: int = 10

# **NEW:** Combo system variables
var combo_count: int = 0
var combo_multiplier: float = 1.0
var combo_timer: float = 0.0
var combo_timeout: float = 2.0
var max_combo_multiplier: float = 5.0

# UI reference
var ui_controller = null

signal score_changed(new_score: int, points_added: int)
# **REMOVED:** multiplier_changed signal (was for time-based system)
# **NEW:** Combo signal
signal combo_changed(combo_count: int, multiplier: float)

func _ready():
	reset_score()

func _process(delta):
	# Time tracking only (no multiplier changes)
	time_survived += delta
	
	# **NEW:** Combo decay system
	if combo_count > 0:
		combo_timer += delta
		if combo_timer >= combo_timeout:
			reset_combo()

# **NEW:** Combo-aware scoring (REPLACES add_block_destroy_score)
func add_combo_score(base_points: int):
	combo_count += 1
	combo_timer = 0.0
	
	# Calculate combo multiplier
	combo_multiplier = min(1.0 + (combo_count * 0.2), max_combo_multiplier)
	
	# Calculate final points (no time multiplier)
	var final_points = base_points * combo_multiplier
	
	current_score += int(final_points)
	blocks_destroyed += 1
	
	# Emit signals
	score_changed.emit(current_score, int(final_points))
	combo_changed.emit(combo_count, combo_multiplier)
	
	print("COMBO x", combo_count, "! Multiplier: x", combo_multiplier, " Points: +", int(final_points))

# **LEGACY:** Keep for backward compatibility
func add_block_destroy_score():
	add_combo_score(block_destroy_points)

# **NEW:** Reset combo system
func reset_combo():
	if combo_count > 0:
		print("Combo ended! Final count: x", combo_count)
	combo_count = 0
	combo_multiplier = 1.0
	combo_timer = 0.0
	combo_changed.emit(combo_count, combo_multiplier)

# **UNCHANGED:** Survival bonus (no multiplier)
func add_survival_bonus():
	var points = survival_bonus_per_second
	current_score += points
	score_changed.emit(current_score, points)

func get_score_text() -> String:
	return str(current_score). pad_zeros(6)

func get_time_text() -> String:
	var minutes = int(time_survived) / 60
	var seconds = int(time_survived) % 60
	return "%02d:%02d" % [minutes, seconds]

func reset_score():
	current_score = 0
	blocks_destroyed = 0
	time_survived = 0.0
	# **REMOVED:** score_multiplier reset
	# **NEW:** Reset combo system
	combo_count = 0
	combo_multiplier = 1.0
	combo_timer = 0.0

func set_ui_controller(ui_ref):
	ui_controller = ui_ref
