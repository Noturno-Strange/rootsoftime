extends RefCounted

const STEP := 12
var grid := AStarGrid2D.new()

func build(land: RefCounted) -> void:
	grid.region = Rect2i(0,0,171,86)
	grid.cell_size = Vector2.ONE*STEP
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	for x in range(171):
		for y in range(86):
			if not land.BOUNDS.has_point(Vector2(x,y)*STEP): grid.set_point_solid(Vector2i(x,y))
	for entry: Node in land.display.find_children("*","CollisionShape2D",true,false):
		var shape := entry as CollisionShape2D
		if not shape.shape is RectangleShape2D: continue
		var size: Vector2 = shape.shape.size
		var r := Rect2(shape.global_position-size/2,size).grow(8)
		for x in range(maxi(0,ceili(r.position.x/STEP)),mini(170,floori(r.end.x/STEP))+1):
			for y in range(maxi(0,ceili(r.position.y/STEP)),mini(85,floori(r.end.y/STEP))+1):
				grid.set_point_solid(Vector2i(x,y))

func walkable(point: Vector2) -> Vector2i:
	var cell := Vector2i((point/STEP).round())
	if grid.is_in_boundsv(cell) and not grid.is_point_solid(cell): return cell
	for radius in range(1,8):
		for x in range(-radius,radius+1):
			for y in range(-radius,radius+1):
				var p := cell+Vector2i(x,y)
				if grid.is_in_boundsv(p) and not grid.is_point_solid(p): return p
	return Vector2i(-1,-1)

func route(from: Vector2, to: Vector2) -> PackedVector2Array:
	var start := walkable(from)
	var end := walkable(to)
	if start.x < 0 or end.x < 0: return PackedVector2Array()
	return grid.get_point_path(start,end)
