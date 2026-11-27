extends Node2D

# Mesa comunitária vista de três quartos. As posições são medidas no tampo.
const PLACES := [Vector2(-30,-49),Vector2(2,-49),Vector2(-13,-39),Vector2(23,-39)]

func face(points: Array, color: String) -> void:
	var polygon := PackedVector2Array(points)
	draw_colored_polygon(polygon,Color(color))
	polygon.append(polygon[0])
	draw_polyline(polygon,Color("#55341f"),1.5,true)

func _draw() -> void:
	for foot: Vector2 in [Vector2(-40,-14),Vector2(34,-14),Vector2(-48,0),Vector2(43,0)]:
		face([foot,foot+Vector2(6,0),foot+Vector2(7,-35),foot+Vector2(0,-35)],"#97623c")
	face([Vector2(-53,-38),Vector2(51,-38),Vector2(51,-31),Vector2(-53,-31)],"#aa7042")
	face([Vector2(51,-38),Vector2(43,-57),Vector2(43,-50),Vector2(51,-31)],"#805135")
	face([Vector2(-53,-38),Vector2(-43,-57),Vector2(43,-57),Vector2(51,-38)],"#dab07a")
	for row in range(1,4):
		var f := row/4.0
		var y := -57.0+19*f
		draw_line(Vector2(-43-10*f,y),Vector2(43+8*f,y),Color("#ad7b50"),1,true)
