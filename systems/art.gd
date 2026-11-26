extends RefCounted

var textures: Dictionary = {}

func _init() -> void:
	var defs: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/atlas.json"))
	for key: String in defs:
		var d: Array = defs[key]
		var texture := AtlasTexture.new()
		texture.atlas = load("res://assets/%s.webp" % d[0])
		texture.region = Rect2(d[1], d[2], d[3], d[4])
		texture.filter_clip = true
		textures[key] = texture

func sprite(key: String, height: float) -> Sprite2D:
	var s := Sprite2D.new()
	paint(s, key, height)
	return s

func paint(s: Sprite2D, key: String, height: float) -> void:
	var tex: Texture2D = textures[key]
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	s.texture = tex
	s.centered = false
	s.offset = Vector2(-tex.get_width() * 0.5, -tex.get_height())
	s.scale = Vector2.ONE * height / tex.get_height()
