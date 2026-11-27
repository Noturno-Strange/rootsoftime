extends RefCounted

const SITES := {
	"well":[Vector2(867,616),"well",115,34], "warehouse":[Vector2(1300,800),"warehouse",187,95],
	"home":[Vector2(365,375),"home",315,170], "mill":[Vector2(765,330),"mill",205,104],
	"school":[Vector2(1245,311),"school",289,181], "stove":[Vector2(548,450),"stove",87,45],
	"table":[Vector2(376,515),"table",66,44], "market":[Vector2(1014,710),"market",155,88],
	"tray":[Vector2(559,562),"shared_table",76,51], "storage":[Vector2(678,528),"chest",48,38], "press":[Vector2(887,358),"press",88,28],
	"wash":[Vector2(565,358),"wash",54,28], "grater":[Vector2(643,375),"grater",55,27],
	"sieve":[Vector2(979,362),"sieve",58,25], "oven":[Vector2(202,449),"clay_oven",91,40],
	"pan":[Vector2(262,567),"iron_griddle",108,61], "mix":[Vector2(165,627),"kneading_bench",65,31],
	"hen":[Vector2(1024,522),"hen",34,8], "cow":[Vector2(1130,787),"cow",73,38],
	"orchard":[Vector2(1200,586),"mango",196,24]
}
const SPAWN := Vector2(457,674)
const CHILD_HOME := Vector2(400,548)
const CHILD_SCHOOL := Vector2(1245,336)
const BOUNDS := Rect2(90,175,1360,755)
var roofs: Dictionary = {}
var scenery_reservations: Array[Rect2] = []
var doorways: Dictionary = {}
var interiors: Dictionary = {}
var anchors: Dictionary = {}
var visuals: Dictionary = {}
var plants: Array[Sprite2D] = []
var beds: Array[Sprite2D] = []
var display: Node2D
var art: RefCounted

func obstacle(parent: Node2D, half_width: float, depth: float) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(half_width * 2,depth)
	shape.shape = rect
	shape.position.y = -depth/2
	body.add_child(shape)
	parent.add_child(body)

func place(key: String, pos: Vector2, height: float, solid: float = 0) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	display.add_child(node)
	var tex: Texture2D = art.textures[key]
	var sprite_width := height*tex.get_width()/tex.get_height()
	node.add_child(art.ground_shadow(sprite_width*0.98,maxf(8,height*0.25)))
	node.add_child(art.sprite(key,height))
	if solid > 0:
		var depth := 116.0 if key == "warehouse" else minf(65,height*0.25)
		obstacle(node,solid,depth)
	return node

func building(key: String, d: Array) -> Node2D:
	var center: Vector2 = d[0]
	var width := float(d[3])*2
	var inside := Node2D.new()
	inside.position = center-Vector2(0,135)
	display.add_child(inside)
	var room: Sprite2D = art.sprite("house_room" if key == "home" else "school_room",width*0.66)
	room.position.y = 135
	inside.add_child(room)
	var extent := width/2-14
	var door := -width*0.14 if key == "school" else -width*0.035
	doorways[key] = door
	var opening := 27.0
	var left := door-opening+extent
	var right := extent-door-opening
	var walls := [[Vector2(0,-65),extent,68],[Vector2(-extent+5,0),5,66],[Vector2(extent-5,0),5,66],
		[Vector2(-extent+left/2,0),left/2,12],[Vector2(extent-right/2,0),right/2,12]]
	for piece: Array in walls:
		var wall := Node2D.new()
		wall.position = center + piece[0]
		display.add_child(wall)
		obstacle(wall,piece[1],piece[2])
	var front := place(key,center,d[2])
	roofs[key] = front
	interiors[key] = inside
	return front

func reveal_rooms(viewer: Vector2, delta: float) -> void:
	for key: String in roofs:
		var relative: Vector2 = viewer - SITES[key][0]
		var doorway := absf(relative.x-float(doorways[key])) < 27 and relative.y <= 10
		var inside := absf(relative.x) < float(SITES[key][3])-14 and relative.y >= -67 and (relative.y < -7 or doorway)
		var roof: Node2D = roofs[key]
		roof.modulate.a = move_toward(roof.modulate.a,0.0 if inside else 1.0,delta*5)
		interiors[key].visible = roof.modulate.a < 0.999

func build(root: Node2D, atlas: RefCounted) -> void:
	art = atlas
	var ground := Sprite2D.new()
	ground.texture = preload("res://assets/ground.webp")
	ground.centered = false
	ground.scale = Vector2(1536,1024)/ground.texture.get_size()
	root.add_child(ground)
	display = Node2D.new()
	display.y_sort_enabled = true
	root.add_child(display)
	for key: String in SITES:
		var d: Array = SITES[key]
		if key in ["home","school"]:
			visuals[key] = building(key,d)
		else:
			visuals[key] = place(d[1],d[0],d[2],d[3])
		anchors[key] = d[0] + Vector2(doorways.get(key,0),12)
		var tex: Texture2D = art.textures[d[1]]
		var size := tex.get_size()*float(d[2])/tex.get_height()
		scenery_reservations.append(Rect2(d[0]-Vector2(size.x/2,size.y),size).grow(5))
	for detail: Array in [
		["geranium",Vector2(282,387),34,11], ["geranium",Vector2(1310,323),29,9],
		["rail",Vector2(453,781),42,24], ["rail",Vector2(520,787),38,22],
		["granite",Vector2(796,707),39,15], ["granite",Vector2(144,805),57,22],
		["geranium",Vector2(1060,726),32,10], ["rail",Vector2(1164,364),45,25],
		["granite",Vector2(1318,564),48,19], ["geranium",Vector2(1380,804),38,12]]:
		place(detail[0],detail[1],detail[2],detail[3])
	for i in range(8):
		var pos := Vector2(460 + (i%4)*90,646 + floori(i/4.0)*83)
		anchors["plot%d" % i] = pos
		var base := Node2D.new()
		base.position = pos
		display.add_child(base)
		var bed: Sprite2D = art.sprite("dry_bed",25)
		bed.flip_h = i%3 == 1
		base.add_child(bed)
		obstacle(base,32,24)
		var seeds := Node2D.new()
		seeds.name = "Seeds"
		base.add_child(seeds)
		for j in 6:
			var grain := Polygon2D.new()
			grain.polygon = PackedVector2Array([Vector2(-2,0),Vector2(0,-1.5),Vector2(2,0),Vector2(0,1)])
			grain.color = Color("#edc378")
			grain.position = Vector2(-20+(j%3)*18,-9-(j/3)*9)
			seeds.add_child(grain)
		beds.append(bed)
		var plant: Sprite2D = art.sprite("seedling",16)
		plant.position.y = -9
		base.add_child(plant)
		plants.append(plant)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1942
	for i in range(18):
		var pos := Vector2(i*94+rng.randf_range(-22,22),rng.randf_range(142,206))
		plant_tree("banana" if i%3==0 else "mango",pos,rng.randf_range(145,225),18)
	for side in [70,1478]:
		for i in range(6):
			plant_tree("mango" if i%2==0 else "banana",Vector2(side+rng.randf_range(-20,20),330+i*120),rng.randf_range(138,199),15)
	for pos in [Vector2(230,455),Vector2(1113,370),Vector2(1090,833),Vector2(278,809)]:
		plant_tree("banana",pos,113,12)


func plant_tree(key: String, pos: Vector2, height: float, trunk: float) -> void:
	var tex: Texture2D = art.textures[key]
	var size := tex.get_size()*height/tex.get_height()
	var canopy := Rect2(pos-Vector2(size.x/2,size.y),size)
	for reserved in scenery_reservations:
		if canopy.intersects(reserved): return
	place(key,pos,height,trunk)

func nearest(pos: Vector2) -> String:
	var best := 68.0
	var target := ""
	for key: String in anchors:
		var dist := pos.distance_to(anchors[key])
		if dist < best:
			best = dist
			target = key
	return target

func refresh(farm: RefCounted) -> void:
	for i in range(plants.size()):
		var p: Dictionary = farm.state.plots[i]
		var stage := int(p.stage)
		plants[i].visible = stage >= 2
		beds[i].texture = art.textures[["dry_bed","tilled_bed","tilled_bed","wet_bed","tilled_bed"][stage]]
		beds[i].get_parent().get_node("Seeds").visible = stage == 2
		if stage < 2: continue
		var key: String = ["corn","cassava","rice","bean"][int(p.crop)]
		var height := 51.0
		if stage == 2: height = 12
		if stage == 3: height = 29
		if p.crop != 0 and stage < 4: key = ["seedling","rootbud","ricebud","beanbud"][int(p.crop)]
		if p.crop == 0 and stage < 4: key = "young" if stage == 3 else "seedling"
		art.paint(plants[i],key,height)
