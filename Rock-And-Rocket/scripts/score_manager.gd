extends Node

# Score tracking variables
var current_score: int = 0
var blocks_destroyed: int = 0
var time_survived: float = 0.0
var score_multiplier: int = 1

# Score values (BALANCE THESE FOR YOUR GAME)
var block_destroy_points: int = 100
var survival_bonus_per_second: int = 10
var multiplier_increase_interval: float = 30.0  # Every 30 seconds

# UI reference
var ui_controller = null

signal score_changed(new_score: int, points_added: int)
signal multiplier_changed(new_multiplier: int)

func _ready():
	# Reset score on game start
	reset_score()

func _process(delta):
	# Continuous survival bonus
	time_survived += delta
	
	# Increase multiplier over time
	var new_multiplier = int(time_survived / multiplier_increase_interval) + 1
	if new_multiplier != score_multiplier:
		score_multiplier = new_multiplier
		multiplier_changed.emit(score_multiplier)

# Called when player destroys a block
func add_block_destroy_score():
	var points = block_destroy_points * score_multiplier
	current_score += points
	blocks_destroyed += 1
	
	# Emit signal for UI animation
	score_changed.emit(current_score, points)
	print("Score: ", current_score, " (+", points, " points)")

# Called periodically for survival bonus
func add_survival_bonus():
	var points = survival_bonus_per_second * score_multiplier
	current_score += points
	score_changed.emit(current_score, points)

# Get formatted score string
func get_score_text() -> String:
	return str(current_score).pad_zeros(6)  # 6-digit padded score

# Get time survived as formatted string
func get_time_text() -> String:
	var minutes = int(time_survived) / 60
	var seconds = int(time_survived) % 60
	return "%02d:%02d" % [minutes, seconds]

# Reset for new game
func reset_score():
	current_score = 0
	blocks_destroyed = 0
	time_survived = 0.0
	score_multiplier = 1

# Set UI reference for direct communication
func set_ui_controller(ui_ref):
	ui_controller = ui_ref
	

# Custom score addition for different block types
func add_custom_score(points: int):
	var final_points = points * score_multiplier
	current_score += final_points
	
	# Emit signal for UI animation
	score_changed.emit(current_score, final_points)
	print("Score: ", current_score, " (+", final_points, " points)")

# Get current difficulty level for UI display
func get_difficulty_level() -> int:
	var difficulty_thresholds = [0, 1000, 3000, 6000, 10000, 15000, 25000, 40000]
	
	for i in range(difficulty_thresholds.size() - 1, -1, -1):
		if current_score >= difficulty_thresholds[i]:
			return i + 1
	
	return 1
