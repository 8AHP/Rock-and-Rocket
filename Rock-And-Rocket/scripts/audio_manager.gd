extends Node

var shoot_sound: AudioStreamPlayer
var explosion_sound: AudioStreamPlayer
var background_music: AudioStreamPlayer
var hit_sound: AudioStreamPlayer
var diffup_sound : AudioStreamPlayer


# **NEW:** Volume control variables
var master_volume: float = 0.7  # 70% default volume
var sfx_volume: float = 0.8     # 80% SFX volume
var music_volume: float = 0.3   # 30% music volume (SUBTLE)

func _ready():
	# Create all audio players
	shoot_sound = AudioStreamPlayer.new()
	explosion_sound = AudioStreamPlayer.new()
	background_music = AudioStreamPlayer.new() 
	hit_sound = AudioStreamPlayer.new()
	diffup_sound = AudioStreamPlayer.new()
	
	add_child(shoot_sound)
	add_child(explosion_sound)
	add_child(background_music)
	add_child(hit_sound)
	add_child(diffup_sound)
	
	# Load sound files
	shoot_sound.stream = load("res://assests/audio/shot.mp3")  # YOUR FILENAME
	explosion_sound.stream = load("res://assests/audio/explosion.mp3") 
	hit_sound.stream = load("res://assests/audio/hit.mp3")
	diffup_sound.stream = load("res://assests/audio/DiffUp.mp3")
	background_music.stream = load("res://assests/audio/background.mp3")  # YOUR MUSIC FILE
	
	# **NEW:** Configure background music
	background_music.autoplay = true
	background_music.stream.loop = true  # **CHANGED:** Enable looping
	
	master_volume = 0.6   # 70% - Never go above 80% for player safety
	sfx_volume = 0.7      # 80% - SFX should be PROMINENT
	music_volume = 0.20   # 25% - Music should be SUBTLE BACKGROUND
	update_volumes()
	
	# Audio configuration
	shoot_sound.max_polyphony = 8
	explosion_sound.max_polyphony = 4

# **NEW:** Volume update system
func update_volumes():
	shoot_sound.volume_db = linear_to_db(master_volume * sfx_volume * 0.6)  # **CHANGED:** 60% of SFX volume
	diffup_sound.volume_db = linear_to_db(master_volume * sfx_volume * 1)
	hit_sound.volume_db = linear_to_db(master_volume * sfx_volume * 0.8)
	explosion_sound.volume_db = linear_to_db(master_volume * sfx_volume * 0.8)  # **CHANGED:** 80% of SFX volume
	background_music.volume_db = linear_to_db(master_volume * music_volume)  # **NEW:** Music volume

# Existing functions
func play_shoot():
	if shoot_sound.stream:
		shoot_sound.play()

func play_explosion():
	if explosion_sound.stream:
		explosion_sound.play()

func play_hit_sound():
	if hit_sound.stream:
		hit_sound.play()

func play_level_up_sound():
	if diffup_sound:
		diffup_sound.play()

# **NEW:** Volume control functions
func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	update_volumes()

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	update_volumes()

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	update_volumes()

# **NEW:** Music control
func play_background_music():
	if background_music.stream and not background_music.playing:
		background_music.play()

func stop_background_music():
	background_music.stop()

func pause_background_music():
	background_music.stream_paused = true

func resume_background_music():
	background_music.stream_paused = false
