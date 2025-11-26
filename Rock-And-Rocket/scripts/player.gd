extends Node2D

var bullet_scene = preload("res://scenes/bullet.tscn")
var bullet_cooldown = 0.22 # time between shots
var bullet_timer = 0.0

# Tweak these for your game feel:
var max_speed = 250
var min_speed = -200
var acceleration = 800
var deceleration = 600
var max_rot_speed = 3.4 # radians/sec
var rot_acceleration = 13.0
var rot_deceleration = 12.0
@onready var anime: AnimatedSprite2D = $AnimatedSprite2D
var velocity = 0.0
var rot_speed = 0.0

func _process(delta):
	var turning = false
	var thrusting = false
	var is_turning_left = Input.is_action_pressed("left")
	var is_turning_right = Input.is_action_pressed("right")
	var is_moving_forward = Input.is_action_pressed("up")
	
	if is_moving_forward:
		anime.play("W")
	elif is_turning_left:
		anime.play("A")
	elif is_turning_right:
		anime.play("D")
	else:
		anime.play("default")
	# ROTATION
	if Input.is_action_pressed("left"):
		rot_speed -= rot_acceleration * delta
		turning = true
	if Input.is_action_pressed("right"):
		rot_speed += rot_acceleration * delta
		turning = true
	# Clamp rotation speed
	rot_speed = clamp(rot_speed, -max_rot_speed, max_rot_speed)
	# Decelerate rotation if no key pressed
	if not turning:
		rot_speed = move_toward(rot_speed, 0, rot_deceleration * delta)
	rotation += rot_speed * delta

	# ACCELERATION
	if Input.is_action_pressed("up"):
		velocity += acceleration * delta
		thrusting = true
	if Input.is_action_pressed("down"):
		velocity -= acceleration * delta
		thrusting = true
	# Clamp speed
	velocity = clamp(velocity, min_speed, max_speed)
	
	# Decelerate speed if no key pressed
	if not thrusting:
		velocity = move_toward(velocity, 0, deceleration * delta)
	
	# MOVE
	var direction = Vector2.UP.rotated(rotation)
	position += direction * velocity * delta
	
	
	bullet_timer -= delta
	if Input.is_action_just_pressed("fire") and bullet_timer <= 0:
		var forward_offset = Vector2.UP.rotated(rotation) * 34  # Your rocket tip height
			
			# First bullet (left side)
		var bullet1 = bullet_scene.instantiate()
		var left_offset = Vector2.LEFT.rotated(rotation) * 12  # Adjust spacing as needed
		bullet1.position = position + forward_offset + left_offset
		bullet1.direction = Vector2.UP.rotated(rotation)
		bullet1.rotation = rotation
		get_parent().get_node("Bullets").add_child(bullet1)
		
		# Second bullet (right side)
		var bullet2 = bullet_scene.instantiate()
		var right_offset = Vector2.RIGHT.rotated(rotation) * 12  # Adjust spacing as needed
		bullet2.position = position + forward_offset + right_offset
		bullet2.direction = Vector2.UP.rotated(rotation)
		bullet2.rotation = rotation
		get_parent().get_node("Bullets").add_child(bullet2)
		bullet_timer = bullet_cooldown
		# play soundSFX
		AudioManager.play_shoot()


func get_velocity() -> float:
	return velocity


var direction: Vector2:
	get:
		return Vector2.UP.rotated(rotation)

func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


# **ADD THIS** to your existing _input() function or create one:
func _input(event):
	# **NEW:** Volume control hotkeys (TEMPORARY FOR TESTING)
	if Input.is_action_just_pressed("ui_up"):
		AudioManager.set_master_volume(AudioManager.master_volume + 0.1)
		print("Master Volume: ", AudioManager.master_volume)  # **DEBUG:**
	
	if Input.is_action_just_pressed("ui_down"):
		AudioManager.set_master_volume(AudioManager.master_volume - 0.1)
		print("Master Volume: ", AudioManager.master_volume)  # **DEBUG:**
	
	if Input.is_action_just_pressed("ui_right"):
		AudioManager.set_music_volume(AudioManager.music_volume + 0.1)
		print("Music Volume: ", AudioManager.music_volume)  # **DEBUG:**
	
	if Input.is_action_just_pressed("ui_left"):
		AudioManager.set_music_volume(AudioManager.music_volume - 0.1)
		print("Music Volume: ", AudioManager.music_volume)  # **DEBUG:**
