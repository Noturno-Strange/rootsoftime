extends Node2D

func _draw() -> void:
	var outline := PackedVector2Array()
	for i in range(48):
		var angle := TAU*i/48
		outline.append(Vector2(cos(angle)*45,sin(angle)*9))
	draw_colored_polygon(outline,Color("#805536"))
	outline.append(outline[0])
	draw_polyline(outline,Color("#d6a960"),2.5,true)
