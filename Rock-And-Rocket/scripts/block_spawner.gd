extends Timer

var block_scene = preload("res://scenes/Block.tscn")
var player_node
var screen_size
var spawn_distance = 800

# **NEW:** Performance limiter
var max_blocks = 100                    # **PERFORMANCE CAP** - Change this number
var current_blocks = 0

# **TUNABLE DIFFICULTY VARIABLES:**
var difficulty_timer = 0.0
var base_spawn_rate = 2.0               # **BASE INTERVAL** - Higher = slower initial spawning

# **SPAWN RATE PROGRESSION:**
var difficulty_speed_multiplier = 1.5   # **PROGRESSION SPEED** - Higher = difficulty increases faster
var difficulty_interval = 15.0          # **ESCALATION EVERY X SECONDS** - Lower = more frequent increases  
var spawn_rate_increase = 1.2          # **SPAWN RATE BOOST** - Higher = more dramatic spawn increases
var minimum_spawn_interval = 0.05      # **MAXIMUM SPAWN SPEED** - Lower = insane spawn rates

# **LEVEL PROGRESSION:**
var difficulty_level: int = 1
var level_interval = 15.0              # **NEW LEVEL EVERY X SECONDS** - Lower = faster level progression
var last_announced_level = 1

# **UI REFERENCE FOR LEVEL ALERTS:**
var ui_controller = null

func _ready():
	player_node = get_parent().get_node("Player")
	player_node.add_to_group("player")
	
	screen_size = get_viewport().get_visible_rect().size
	wait_time = base_spawn_rate
	timeout.connect(_on_timer_timeout)
	
	# **NEW:** Get UI reference for level alerts
	ui_controller = get_tree().get_first_node_in_group("game_ui")
	start()

func _process(delta):
	# **NEW:** Performance tracking
	current_blocks = get_parent().get_node("Blocks").get_child_count()
	
	# **TUNABLE:** Difficulty progression formula
	difficulty_timer += delta * difficulty_speed_multiplier
	var difficulty_multiplier = 1.0 + (difficulty_timer / difficulty_interval) * spawn_rate_increase
	
	# **TUNABLE:** Spawn rate calculation  
	wait_time = base_spawn_rate / difficulty_multiplier
	wait_time = max(wait_time, minimum_spawn_interval)
	
	# **NEW:** Level progression with alerts
	var new_level = int(difficulty_timer / level_interval) + 1
	if new_level > difficulty_level:
		difficulty_level = new_level
		trigger_level_up_alert()

func _on_timer_timeout():
	# **NEW:** Performance limit (prevents lag)
	if current_blocks >= max_blocks:
		print("Performance limit reached: ", current_blocks, "/", max_blocks, " blocks")
		return
	
	spawn_block()

func spawn_block():
	var block = block_scene.instantiate()
	block.block_type = select_block_type()
	
	var player_pos = player_node.position
	var spawn_pos = get_random_edge_position(player_pos)
	block.position = spawn_pos
	
	# **MORE AGGRESSIVE TARGETING AT HIGHER LEVELS:**
	var target_variance = max(50, 200 - (difficulty_level * 20))
	var target_area = player_pos + Vector2(
		randf_range(-target_variance, target_variance),
		randf_range(-target_variance, target_variance)
	)
	block.set_target(target_area)
	
	get_parent().get_node("Blocks").add_child(block)

# **ENHANCED:** Block type selection with level progression
func select_block_type() -> int:
	match difficulty_level:
		1: # LEVEL 1: Basic blocks only
			return randi_range(1, 2)
		2: # LEVEL 2: Add fast blocks  
			var rand = randf()
			if rand < 0.6: return randi_range(1, 2)
			else: return 3
		3: # LEVEL 3: Add armored blocks
			var rand = randf()
			if rand < 0.4: return randi_range(1, 2)
			elif rand < 0.7: return 3
			else: return 4
		_: # LEVEL 4+: All block types
			var rand = randf()
			if rand < 0.3: return randi_range(1, 2)
			elif rand < 0.6: return 3
			else: return 4

# **NEW:** Level up alert system
func trigger_level_up_alert():
	# **ENHANCED:** Check for UI reference
	ui_controller = get_tree().get_first_node_in_group("game_ui")
	if ui_controller:
		print("UI controller found: ", ui_controller)
		if ui_controller.has_method("show_level_up_alert"):
			ui_controller. show_level_up_alert(difficulty_level)
		else:
			print("ERROR: show_level_up_alert method not found!")
	else:
		print("ERROR: UI controller not found in 'game_ui' group!")
		print("Available groups: ", get_tree().get_nodes_in_group("game_ui"))
	
	# Screen shake for level up
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("add_shake"):
		camera.add_shake(30.0, 1.0)
		print("Level up screen shake triggered")
	
	if AudioManager and AudioManager.has_method("play_level_up_sound"):
		AudioManager.play_level_up_sound()  # **HIGHLIGHTED: LEVEL UP SOUND**
		print("Level up sound triggered")
	else:
		print("AudioManager or play_level_up_sound not found")
	
	# **NEW:** Trigger UI alert
	if ui_controller and ui_controller.has_method("show_level_up_alert"):
		ui_controller.show_level_up_alert(difficulty_level)
	
	# **NEW:** Screen shake for level up
	if camera and camera.has_method("add_shake"):
		camera.add_shake(30.0, 1.0)  # **STRONG SHAKE FOR LEVEL UP**
	
	# **NEW:** Audio feedback
	if AudioManager and AudioManager.has_method("play_level_up_sound"):
		AudioManager.play_level_up_sound()

func get_random_edge_position(center: Vector2) -> Vector2:
	var edge = randi() % 4
	var spawn_pos = Vector2()
	
	# **DYNAMIC SPAWN DISTANCE:**
	var current_spawn_distance = spawn_distance + (difficulty_level * 100)
	
	match edge:
		0: # Top
			spawn_pos.x = center.x + randf_range(-current_spawn_distance, current_spawn_distance)
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

# **NEW:** Difficulty info for UI
func get_difficulty_info() -> Dictionary:
	return {
		"level": difficulty_level,
		"spawn_rate": 1.0 / wait_time,
		"blocks_active": current_blocks,
		"blocks_max": max_blocks
	}
