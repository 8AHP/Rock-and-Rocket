extends Timer

var block_scene = preload("res://scenes/Block.tscn")
var player_node
var screen_size
var spawn_distance = 800
var max_blocks = 100  # NEW: Maximum simultaneous blocks
var current_blocks = 0  # NEW: Block counter
var difficulty_timer = 0.0  # NEW: For difficulty progression
var base_spawn_rate = 1.0  # NEW: Base spawn interval

func _ready():
	player_node = get_parent().get_node("Player")
	# NEW: Add player to group for easy reference
	player_node.add_to_group("player")
	
	screen_size = get_viewport().get_visible_rect().size
	wait_time = base_spawn_rate
	timeout.connect(_on_timer_timeout)
	start()

func _process(delta):
	# NEW: Update block count (PERFORMANCE TRACKING)
	current_blocks = get_parent().get_node("Blocks").get_child_count()
	
	# NEW: Difficulty progression (SETUP FOR PART C)
	difficulty_timer += delta * 1.5
	var difficulty_multiplier = 1.0 + (difficulty_timer / 10.0) * 0.5  # Increase every n seconds
	wait_time = base_spawn_rate / difficulty_multiplier
	wait_time = max(wait_time, 0.005)  # Never faster than n seconds

func _on_timer_timeout():
	# NEW: Rate limiting (PERFORMANCE PROTECTION)
	if current_blocks >= max_blocks:
		print("Max blocks reached, skipping spawn")  # DEBUG
		return
		
	spawn_block()

func spawn_block():
	var block = block_scene.instantiate()
	block.block_type = randi_range(1, 2)
	
	var player_pos = player_node.position
	var spawn_pos = get_random_edge_position(player_pos)
	block.position = spawn_pos
	
	var target_area = player_pos + Vector2(randf_range(-200, 200), randf_range(-200, 200))
	block.set_target(target_area)
	
	get_parent().get_node("Blocks").add_child(block)
	current_blocks += 1  # NEW: Update counter

func get_random_edge_position(center: Vector2) -> Vector2:
	var edge = randi() % 4
	var spawn_pos = Vector2()
	
	match edge:
		0: # Top
			spawn_pos.x = center.x + randf_range(-spawn_distance, spawn_distance)
			spawn_pos.y = center.y - spawn_distance
		1: # Right
			spawn_pos.x = center.x + spawn_distance
			spawn_pos.y = center.y + randf_range(-spawn_distance, spawn_distance)
		2: # Bottom
			spawn_pos.x = center.x + randf_range(-spawn_distance, spawn_distance)
			spawn_pos.y = center.y + spawn_distance
		3: # Left
			spawn_pos.x = center.x - spawn_distance
			spawn_pos.y = center.y + randf_range(-spawn_distance, spawn_distance)
	
	return spawn_pos
