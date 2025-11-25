extends Node2D

@export var block_type: int = 1
@export var speed: float = 100.0
@export var rotation_speed: float = 2.0

var target_position: Vector2
var direction: Vector2
var lifetime = 35.0  # NEW: Maximum block lifetime
var max_distance_from_player = 1000.0  # NEW: Cleanup distance

func _ready():
	setup_block_type()
	rotation_speed = randf_range(1.0, 4.0) * (1 if randf() > 0.5 else -1)
	speed += randf_range(-50,250)

func setup_block_type():
	match block_type:
		1:
			$Sprite2D.texture = preload("res://assests/block1.png")
			$Area2D/CollisionType1.disabled = false
			$Area2D/CollisionType2.disabled = true
		2:
			$Sprite2D.texture = preload("res://assests/block2.png")
			$Area2D/CollisionType1.disabled = true
			$Area2D/CollisionType2.disabled = false

func _process(delta):
	position += direction * speed * delta
	rotation += rotation_speed * delta
	
	# NEW: Lifetime cleanup (PERFORMANCE CRITICAL)
	lifetime -= delta
	if lifetime < 0:
		queue_free()
		return
	
	# NEW: Distance-based cleanup (MEMORY SAVER)
	var player = get_tree().get_first_node_in_group("player")
	if player and position.distance_to(player.position) > max_distance_from_player:
		queue_free()

func set_target(target: Vector2):
	target_position = target
	direction = (target_position - position).normalized()

func _on_area_2d_area_entered(area):
	if area.get_parent().name == "Player":
		print("Game Over! Player hit by block!")
		get_tree().paused = true
