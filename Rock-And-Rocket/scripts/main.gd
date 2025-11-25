extends Node2D

func _ready():
	# **NEW:** Start background music when game loads
	AudioManager.play_background_music()
	print("Background music started")  # **DEBUG:**
