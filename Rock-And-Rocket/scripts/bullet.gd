extends Node2D

var speed = 1300.0
var direction = Vector2.ZERO
var lifetime = 2.5
var max_distance = 1500.0
var start_position: Vector2

var explosion_scene = preload("res://scenes/explosion.tscn")

func _ready():
	$AnimatedSprite2D.play("default")
	start_position = position

func _process(delta):
	position += direction * speed * delta
	lifetime -= delta
	
	if lifetime < 0:
		queue_free()
		return
	
	if position.distance_to(start_position) > max_distance:
		queue_free()
		return
	
	var screen_bounds = get_viewport_rect().size
	var camera_pos = get_viewport().get_camera_2d().global_position
	var distance_from_camera = position.distance_to(camera_pos)
	if distance_from_camera > screen_bounds.length() * 2:
		queue_free()

func _on_area_2d_area_entered(area):
	if area.get_parent(). has_method("setup_block_type"):
		var block = area.get_parent()
		
		# Create explosion at impact point
		create_explosion()
		
		# Trigger screen shake
		var camera = get_viewport().get_camera_2d()
		if camera.has_method("add_shake"):
			camera.add_shake(15.0, 0.3)
		
		# Play explosion sound
		AudioManager.play_explosion()
		
		# **CHANGED:** Call take_damage instead of immediate destruction
		if block.has_method("take_damage"):
			block.take_damage()  # **HIGHLIGHTED: USE HEALTH SYSTEM**
		else:
			# **FALLBACK:** Old blocks without health system
			ScoreManager.add_block_destroy_score()
			block.queue_free()
		
		queue_free()

func create_explosion():
	var explosion = explosion_scene.instantiate()
	explosion.position = position
	get_parent().add_child(explosion)
