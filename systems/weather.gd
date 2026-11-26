extends CPUParticles2D

func _ready() -> void:
	amount = 130
	lifetime = 0.9
	preprocess = 0.9
	emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	emission_rect_extents = Vector2(830,400)
	direction = Vector2(-0.18,1)
	spread = 2
	initial_velocity_min = 330
	initial_velocity_max = 400
	gravity = Vector2(-14,100)
	scale_amount_min = 0.8
	scale_amount_max = 1.1
	var img := Image.create_empty(3,15,false,Image.FORMAT_RGBA8)
	for y in range(14):
		img.set_pixel(2-int(y/6.0),y,Color(0.78,0.88,0.96,0.45))
	texture = ImageTexture.create_from_image(img)
	emitting = false
	local_coords = false

static func raining(time: float) -> bool:
	return fmod(time,240.0) >= 181.0
