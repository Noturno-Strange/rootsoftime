extends Node2D

const HEIGHT := 116.0

# Only the awning and embroidered counter come from the old market illustration.
func strip(source: AtlasTexture, top: float, bottom: float) -> Sprite2D:
	var crop := AtlasTexture.new()
	crop.atlas = source.atlas
	var rect := source.region
	crop.region = Rect2(rect.position + Vector2(0,rect.size.y*top),Vector2(rect.size.x,rect.size.y*(bottom-top)))
	crop.filter_clip = true
	var sprite := Sprite2D.new()
	sprite.texture = crop
	sprite.centered = false
	sprite.scale = Vector2.ONE * HEIGHT/rect.size.y
	sprite.position = Vector2(-rect.size.x*sprite.scale.x/2,HEIGHT*(top-1.0))
	add_child(sprite)
	return sprite

func setup(art: RefCounted, key: String, wares: Array) -> void:
	var source: AtlasTexture = art.textures[key]
	var width := HEIGHT*source.region.size.x/source.region.size.y
	add_child(art.ground_shadow(width,19))
	for side in [-1,1]:
		var post := Line2D.new()
		var x: float = width*0.42*side
		post.points = PackedVector2Array([Vector2(x,-99),Vector2(x, -3)])
		post.width = 4.5
		post.default_color = Color("#865632")
		add_child(post)
		var edge := Line2D.new()
		edge.points = PackedVector2Array([Vector2(x-1,-97),Vector2(x-1,-5)])
		edge.width = 1.2
		edge.default_color = Color("#c19760")
		add_child(edge)
	strip(source,0.0,0.19)
	var counter := strip(source,0.79,1.0)
	counter.scale.y *= 1.5
	counter.position.y *= 1.5
	var shelf := Polygon2D.new()
	shelf.polygon = PackedVector2Array([Vector2(-width*0.46,-37),Vector2(-width*0.39,-43),Vector2(width*0.44,-43),Vector2(width*0.47,-37)])
	shelf.color = Color("#ac794b")
	add_child(shelf)
	for row in 2:
		for i in wares.size():
			var product: Sprite2D = art.sprite(wares[i],16 if row == 0 else 13)
			product.position = Vector2((i-1)*width*0.26+row*6,-41+row*4)
			add_child(product)
