extends ParallaxLayer

func _ready():
	print("Layer initialized: ", name)  # **HIGHLIGHTED: EXISTENCE CONFIRMATION**
	print("Motion scale: ", motion_scale)  # **HIGHLIGHTED: MOVEMENT VERIFICATION**
	print("Motion mirroring: ", motion_mirroring)  # **HIGHLIGHTED: TILING VERIFICATION**
	
	# **NEW:** Force visibility check for child sprites
	for child in get_children():
		if child is Sprite2D:
			print("Sprite found: ", child.name)  # **HIGHLIGHTED: SPRITE DETECTION**
			print("Sprite texture: ", child.texture)  # **HIGHLIGHTED: TEXTURE VERIFICATION**
			print("Sprite modulate: ", child.modulate)  # **HIGHLIGHTED: TRANSPARENCY CHECK**
			print("Sprite position: ", child.position)  # **HIGHLIGHTED: POSITION VERIFICATION**
			
			# **NEW:** Force sprite to be visible with bright color
			child.modulate = Color.RED  # **HIGHLIGHTED: FORCE VISIBILITY WITH RED**
			child.z_index = 10  # **HIGHLIGHTED: FORCE TO FOREGROUND**
