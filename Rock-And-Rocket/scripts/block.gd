extends Node2D

@export var block_type: int = 1
@export var speed: float = 100.0
@export var rotation_speed: float = 2.0

var target_position: Vector2
var direction: Vector2
var lifetime = 15.0
var max_distance_from_player = 2000.0

# **NEW:** Enhanced block properties
var health: int = 1
var score_value: int = 10
var special_behavior: String = "normal"

func _ready():
	setup_block_type()
	rotation_speed = randf_range(1.0, 4.0) * (1 if randf() > 0.5 else -1)
	# **CHANGED:** Speed variation based on type
	apply_type_modifiers()

func setup_block_type():
	match block_type:
		1: # BASIC ROCK (unchanged)
			$Sprite2D.texture = preload("res://assests/block1.png")
			$Area2D/CollisionType1.disabled = false
			$Area2D/CollisionType2.disabled = true
			$Area2D/CollisionType3.disabled = true
			$Area2D/CollisionType4.disabled = true
			health = 1
			score_value = 10
			special_behavior = "normal"
			
		2: # HEAVY ROCK (unchanged)
			$Sprite2D.texture = preload("res://assests/block4.png") 
			$Area2D/CollisionType1.disabled = true
			$Area2D/CollisionType2.disabled = true
			$Area2D/CollisionType3.disabled = true
			$Area2D/CollisionType4.disabled = false
			health = 1
			score_value = 15
			special_behavior = "normal"
			
		3: # **NEW:** FAST ROCK - High speed, low health
			$Sprite2D.texture = preload("res://assests/block2.png")
			$Sprite2D.modulate = Color. YELLOW  # **HIGHLIGHTED: VISUAL DISTINCTION**
			$Area2D/CollisionType1.disabled = true
			$Area2D/CollisionType2.disabled = false
			$Area2D/CollisionType3.disabled = true
			$Area2D/CollisionType4.disabled = true
			health = 1
			score_value = 20
			special_behavior = "fast"
			speed *= 2.5  # **HIGHLIGHTED: MUCH FASTER**
			
		4: # **NEW:** ARMORED ROCK - Slow but tough
			$Sprite2D.texture = preload("res://assests/block3.png")
			$Sprite2D.modulate = Color.DARK_GRAY  # **HIGHLIGHTED: VISUAL DISTINCTION**
			$Area2D/CollisionType1.disabled = true  
			$Area2D/CollisionType2.disabled = true
			$Area2D/CollisionType3.disabled = false
			$Area2D/CollisionType4.disabled = true
			health = 3  # **HIGHLIGHTED: TAKES 3 HITS**
			score_value = 30
			special_behavior = "armored"
			speed *= 0.6  # **HIGHLIGHTED: SLOWER MOVEMENT**
			
		5: # **NEW:** ERRATIC ROCK - Unpredictable movement
			$Sprite2D.texture = preload("res://assests/block2.png")
			$Sprite2D.modulate = Color.MAGENTA  # **HIGHLIGHTED: VISUAL DISTINCTION**
			$Area2D/CollisionType1.disabled = true
			$Area2D/CollisionType2.disabled = false
			$Area2D/CollisionType3.disabled = true
			$Area2D/CollisionType4.disabled = true
			health = 1
			score_value = 25
			special_behavior = "erratic"
			rotation_speed *= 3.0  # **HIGHLIGHTED: WILD SPINNING**

func apply_type_modifiers():
	# **NEW:** Apply speed variations based on difficulty
	var difficulty_speed_bonus = ScoreManager.score_multiplier * 0.2
	speed += speed * difficulty_speed_bonus

func _process(delta):
	# **CHANGED:** Enhanced movement with special behaviors
	match special_behavior:
		"normal", "armored":
			position += direction * speed * delta
		"fast":
			position += direction * speed * delta
		"erratic":
			# **NEW:** Erratic movement pattern
			var wobble = Vector2(sin(Time.get_time_dict_from_system().second * 5) * 50, cos(Time. get_time_dict_from_system(). second * 3) * 30)
			position += (direction * speed + wobble) * delta
	
	rotation += rotation_speed * delta
	
	# Existing cleanup logic
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

func take_damage():
	health -= 1
	
	# **NEW:** Visual damage feedback
	var flash_tween = create_tween()
	flash_tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)
	flash_tween.tween_property($Sprite2D, "modulate", $Sprite2D. modulate, 0.1)
	
	if health <= 0:
		# **NEW:** Award points based on block value
		ScoreManager.add_custom_score(score_value)
		queue_free()
	else:
		# **NEW:** Damage sound for armored blocks
		AudioManager.play_hit_sound()  # Add this sound to AudioManager

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "Player":
		print("Game Over! Player hit by block!")
		get_tree().paused = true
