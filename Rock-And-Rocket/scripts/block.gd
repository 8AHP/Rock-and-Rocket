extends Node2D

@export var block_type: int = 1
@export var speed: float = 100.0
@export var rotation_speed: float = 2.0

var target_position: Vector2
var direction: Vector2
var lifetime = 35.0
var max_distance_from_player = 2000.0

# Health and scoring system
var health: int = 1
var max_health: int = 1
var score_value: int = 100
var special_behavior: String = "normal"

func _ready():
	setup_block_type()
	rotation_speed = randf_range(1.0, 4.0) * (1 if randf() > 0.5 else -1)
	speed += randf_range(-50, 250)
	apply_difficulty_modifiers()

func setup_block_type():
	# Disable all collision types first
	$Area2D/CollisionType1.disabled = true
	$Area2D/CollisionType2.disabled = true
	$Area2D/CollisionType3.disabled = true
	$Area2D/CollisionType4.disabled = true
	
	match block_type:
		1: # BASIC ROCK
			$Sprite2D.texture = preload("res://assests/block1.png")
			$Area2D/CollisionType1. disabled = false
			health = 1
			max_health = 1
			score_value = 100
			special_behavior = "normal"
			
		2: # HEAVY ROCK
			$Sprite2D.texture = preload("res://assests/block2.png")
			$Area2D/CollisionType2.disabled = false
			health = 1
			max_health = 1
			score_value = 150
			special_behavior = "normal"
			
		3: # FAST ROCK - Block3 sprite
			$Sprite2D.texture = preload("res://assests/block3.png")
			$Area2D/CollisionType3. disabled = false
			$Sprite2D.modulate = Color.YELLOW
			health = 1
			max_health = 1
			score_value = 200
			special_behavior = "fast"
			speed *= 2.5
			
		4: # ARMORED ROCK - Block4 sprite
			$Sprite2D.texture = preload("res://assests/block4.png")
			$Area2D/CollisionType4.disabled = false
			$Sprite2D. modulate = Color. GRAY
			health = 3
			max_health = 3
			score_value = 300
			special_behavior = "armored"
			speed *= 0.6

# **FIXED:** Replace score_multiplier with time-based difficulty
func apply_difficulty_modifiers():
	
	if ScoreManager:
		# **CHANGED:** Use time_survived instead of removed score_multiplier
		var time_difficulty = ScoreManager.time_survived / 30.0
		# **SPEED INTERVAL** (30.0 = every 30 sec)
		var difficulty_bonus = min(time_difficulty * 0.2, 2.0)
		# **SPEED INCREASE RATE** (0.2 = 20% per interval)
	## **BREAKDOWN:**
# / 30.0              = How often speed increases (30.0 = every 30 sec, 15.0 = every 15 sec)
# * 0.2               = Speed increase per interval (0.2 = 20%, 0.5 = 50%)
# , 2.0               = Maximum speed multiplier (2.0 = 3x total speed, 1.0 = 2x total speed)
		speed += speed * difficulty_bonus
		
		print("Block speed increased by: ", difficulty_bonus * 100, "% (time: ", ScoreManager.time_survived, "s)")  # **DEBUG**


## **ALTERNATIVE**

#func apply_difficulty_modifiers():
	#if ScoreManager:
		## **ALTERNATIVE:** Use combo multiplier for difficulty
		#var combo_difficulty = ScoreManager. combo_multiplier - 1.0  # **HIGHLIGHTED: COMBO-BASED**
		#var difficulty_bonus = combo_difficulty * 0.3  # **HIGHLIGHTED: 30% PER COMBO LEVEL**
		#speed += speed * difficulty_bonus
		#
		#print("Block speed increased by combo: ", difficulty_bonus * 100, "% (combo: x", ScoreManager. combo_multiplier, ")")


func _process(delta):
	match special_behavior:
		"normal", "armored":
			position += direction * speed * delta
		"fast":
			position += direction * speed * delta
		"erratic":
			var time = Time.get_time_dict_from_system()
			var wobble = Vector2(
				sin(time.second * 5 + position.x * 0.01) * 50,
				cos(time.second * 3 + position.y * 0.01) * 30
			)
			position += (direction * speed + wobble) * delta
	
	rotation += rotation_speed * delta
	
	lifetime -= delta
	if lifetime < 0:
		queue_free()
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player and position.distance_to(player.position) > max_distance_from_player:
		queue_free()

func set_target(target: Vector2):
	target_position = target
	direction = (target_position - position).normalized()

# Health system with combo integration
func take_damage():
	health -= 1
	
	# Visual damage feedback
	var flash_tween = create_tween()
	flash_tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)
	flash_tween.tween_property($Sprite2D, "modulate", get_original_color(), 0.1)
	
	if health <= 0:
		# Award points and trigger combo
		ScoreManager.add_combo_score(score_value)
		queue_free()
	else:
		update_health_visual()

func get_original_color() -> Color:
	match block_type:
		3: return Color. YELLOW
		4: return Color.GRAY
		_: return Color.WHITE

func update_health_visual():
	var health_ratio = float(health) / float(max_health)
	var damage_tint = Color.RED. lerp(get_original_color(), health_ratio)
	$Sprite2D.modulate = damage_tint

func _on_area_2d_area_entered(area):
	if area. get_parent().name == "Player":
		print("Game Over! Player hit by block!")
		get_tree().paused = true
