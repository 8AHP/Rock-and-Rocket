extends Node2D

var speed = 1867.0
var direction = Vector2.ZERO
var lifetime = 2.5
var max_distance = 1500.0
var start_position: Vector2

# **NEW:** Explosion scene reference
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
	if area.get_parent().has_method("setup_block_type"):
		# **NEW:** Create explosion at impact point
		#create_explosion()
		
		# **NEW:** Trigger screen shake
		var camera = get_viewport().get_camera_2d()
		if camera.has_method("add_shake"):
			camera.add_shake(15.0, 0.3)
		
		# **NEW:** Play explosion sound
		AudioManager.play_explosion()
		
		area.get_parent().queue_free()
		queue_free()

# **NEW:** Explosion creation function
func create_explosion():
	var explosion = explosion_scene.instantiate()
	explosion.position = position
	get_parent().add_child(explosion)
