extends Timer

var block_scene = preload("res://scenes/Block.tscn")
var player_node
var screen_size
var spawn_distance = 800
var max_blocks = 100
var current_blocks = 0

# **NEW:** Advanced difficulty system
var difficulty_level: int = 1
var base_spawn_rate = 1.0
var current_spawn_rate: float
var difficulty_check_timer: float = 0.0
var last_escalation_score: int = 0

# **NEW:** Difficulty progression thresholds
var difficulty_thresholds = [0, 1000, 3000, 6000, 10000, 15000, 25000, 40000]
var spawn_rate_multipliers = [1.0, 1.5, 2.2, 3.0, 4.0, 5.5, 7.0, 10.0]
var max_blocks_per_level = [15, 25, 35, 50, 65, 80, 100, 150]

# **NEW:** Block type probabilities per difficulty level
var block_type_probabilities = {
	1: [70, 30, 0, 0, 0],      # Level 1: 70% type1, 30% type2
	2: [60, 30, 10, 0, 0],     # Level 2: Add 10% fast blocks
	3: [50, 25, 15, 10, 0],    # Level 3: Add armored blocks
	4: [40, 25, 20, 10, 5],    # Level 4: Add erratic blocks
	5: [30, 25, 25, 15, 5],    # Level 5: More variety
	6: [25, 20, 25, 20, 10],   # Level 6: Balanced chaos
	7: [20, 20, 25, 25, 10],   # Level 7: Heavy emphasis on tough blocks
	8: [15, 15, 30, 25, 15]    # Level 8: Maximum chaos
}

# **NEW:** Special event system
var escalation_events = ["spawn_burst", "speed_spike", "armored_wave", "chaos_mode"]
var event_timer: float = 0.0
var active_event: String = ""
var event_duration: float = 0.0

func _ready():
	player_node = get_parent().get_node("Player")
	player_node.add_to_group("player")
	
	screen_size = get_viewport().get_visible_rect().size
	current_spawn_rate = base_spawn_rate
	wait_time = current_spawn_rate
	timeout.connect(_on_timer_timeout)
	
	# **NEW:** Connect to score system for difficulty triggers
	ScoreManager.score_changed.connect(_on_score_changed)
	start()

func _process(delta):
	current_blocks = get_parent().get_node("Blocks").get_child_count()
	difficulty_check_timer += delta
	event_timer += delta
	
	# **NEW:** Check for difficulty level increases
	check_difficulty_progression()
	
	# **NEW:** Handle special events
	handle_escalation_events(delta)
	
	# **NEW:** Update spawn rate based on current difficulty
	update_spawn_rate()

func check_difficulty_progression():
	var current_score = ScoreManager.current_score
	
	# **NEW:** Check if we should increase difficulty level
	for i in range(difficulty_thresholds. size()):
		if current_score >= difficulty_thresholds[i] and difficulty_level <= i + 1:
			if difficulty_level != i + 1:
				escalate_difficulty(i + 1)
				difficulty_level = i + 1
				break

func escalate_difficulty(new_level: int):
	print("DIFFICULTY ESCALATION!  Level ", new_level)  # **DEBUG**
	
	# **NEW:** Update spawn parameters
	max_blocks = max_blocks_per_level[new_level - 1]
	
	# **NEW:** Trigger escalation event
	trigger_escalation_event()
	
	# **NEW:** Visual/Audio feedback for difficulty increase
	trigger_difficulty_feedback()

func trigger_escalation_event():
	# **NEW:** Random special event when difficulty increases
	if difficulty_level >= 3:  # Events start from level 3
		active_event = escalation_events[randi() % escalation_events.size()]
		event_duration = randf_range(8.0, 15.0)  # Event lasts 8-15 seconds
		event_timer = 0.0
		
		print("ESCALATION EVENT: ", active_event)  # **DEBUG**

func handle_escalation_events(delta):
	if active_event != "" and event_timer < event_duration:
		match active_event:
			"spawn_burst":
				# **NEW:** Temporarily spawn blocks much faster
				current_spawn_rate = base_spawn_rate * 0.2
			"speed_spike": 
				# **NEW:** All blocks move faster (handled in block.gd)
				pass
			"armored_wave":
				# **NEW:** Only spawn armored blocks temporarily
				pass
			"chaos_mode":
				# **NEW:** Spawn only erratic and fast blocks
				pass
	else:
		# **NEW:** Event ended, return to normal
		if active_event != "":
			active_event = ""
			print("Escalation event ended")  # **DEBUG**

func update_spawn_rate():
	if active_event == "":  # Normal difficulty scaling
		var multiplier = spawn_rate_multipliers[min(difficulty_level - 1, spawn_rate_multipliers.size() - 1)]
		current_spawn_rate = base_spawn_rate / multiplier
		current_spawn_rate = max(current_spawn_rate, 0.1)  # Minimum spawn interval
	
	wait_time = current_spawn_rate

func select_block_type() -> int:
	# **NEW:** Select block type based on difficulty probabilities
	var probabilities = block_type_probabilities.get(difficulty_level, [70, 30, 0, 0, 0])
	
	# **NEW:** Handle special events
	match active_event:
		"armored_wave":
			return 4  # Only armored blocks
		"chaos_mode":
			return randi_range(3, 5)  # Only special blocks
		_:
			# **NEW:** Normal probability selection
			var random_value = randi() % 100
			var cumulative = 0
			
			for i in range(probabilities.size()):
				cumulative += probabilities[i]
				if random_value < cumulative:
					return i + 1
			
			return 1  # Fallback

func _on_timer_timeout():
	if current_blocks >= max_blocks:
		return
	spawn_block()

func spawn_block():
	var block = block_scene.instantiate()
	
	# **CHANGED:** Use new block type selection
	block.block_type = select_block_type()
	
	var player_pos = player_node.position
	var spawn_pos = get_random_edge_position(player_pos)
	block.position = spawn_pos
	
	# **NEW:** More aggressive targeting at higher difficulties
	var target_variance = max(100, 300 - (difficulty_level * 30))
	var target_area = player_pos + Vector2(
		randf_range(-target_variance, target_variance),
		randf_range(-target_variance, target_variance)
	)
	block.set_target(target_area)
	
	get_parent().get_node("Blocks").add_child(block)
	current_blocks += 1

func get_random_edge_position(center: Vector2) -> Vector2:
	var edge = randi() % 4
	var spawn_pos = Vector2()
	
	# **NEW:** Spawn distance varies with difficulty
	var current_spawn_distance = spawn_distance + (difficulty_level * 50)
	
	match edge:
		0: # Top
			spawn_pos. x = center.x + randf_range(-current_spawn_distance, current_spawn_distance)
			spawn_pos.y = center.y - current_spawn_distance
		1: # Right
			spawn_pos.x = center. x + current_spawn_distance
			spawn_pos. y = center.y + randf_range(-current_spawn_distance, current_spawn_distance)
		2: # Bottom
			spawn_pos. x = center.x + randf_range(-current_spawn_distance, current_spawn_distance)
			spawn_pos.y = center.y + current_spawn_distance
		3: # Left
			spawn_pos.x = center.x - current_spawn_distance
			spawn_pos.y = center.y + randf_range(-current_spawn_distance, current_spawn_distance)
	
	return spawn_pos

func _on_score_changed(new_score: int, points_added: int):
	# **NEW:** React to score milestones for difficulty scaling
	pass

func trigger_difficulty_feedback():
	# **NEW:** Screen flash and sound for difficulty increase
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("add_shake"):
		camera.add_shake(25.0, 0.8)  # Strong shake for difficulty increase
	
	# **NEW:** Audio feedback
	AudioManager.play_difficulty_increase_sound()  # Add this sound
