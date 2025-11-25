extends Node2D

@onready var particles = $GPUParticles2D

func _ready():
	# **NEW:** Configure particle explosion
	particles.emitting = true
	particles.amount = 50
	particles.lifetime = 1.0
	
	# **NEW:** Auto-cleanup after particles finish
	var timer = Timer.new()
	timer.wait_time = 2.0  # Longer than particle lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_cleanup_timer)
	add_child(timer)
	timer.start()

func _on_cleanup_timer():
	queue_free()
