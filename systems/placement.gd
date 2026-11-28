extends RefCounted

const SITES := {
	"well":[Vector2(867,616),"well",115,34], "warehouse":[Vector2(1300,800),"warehouse",187,95],
	"home":[Vector2(365,375),"home",315,170], "mill":[Vector2(765,330),"mill",205,104],
	"school":[Vector2(1245,311),"school",289,181], "stove":[Vector2(555,462),"stove",100,54],
	"table":[Vector2(377,529),"table",76,44],
	"tray":[Vector2(559,562),"shared_table",76,51], "storage":[Vector2(698,534),"chest",56,30], "press":[Vector2(887,358),"press",88,28],
	"wash":[Vector2(591,381),"wash",65,29], "grater":[Vector2(683,397),"grater",66,28],
	"sieve":[Vector2(979,362),"sieve",58,25], "oven":[Vector2(214,461),"clay_oven",106,45],
	"pan":[Vector2(253,570),"iron_griddle",103,54], "mix":[Vector2(165,627),"kneading_bench",65,31],
	"hen":[Vector2(1024,522),"hen",34,8], "cow":[Vector2(1130,787),"cow",73,38],
	"orchard":[Vector2(1200,586),"mango",196,24]
}
const SPAWN := Vector2(457,674)
const CHILD_HOME := Vector2(400,548)
const CHILD_SCHOOL := Vector2(1245,336)
const WORLD_SIZE := Vector2(2560,1664)
const BOUNDS := Rect2(90,175,2390,1420)
const Farm = preload("res://systems/farm.gd")
var dropped: Dictionary = {}
var fruit_shadows: Dictionary = {}
const BOOTHS := ["market","fruit_stall","grain_stall","dairy_stall"]
const FEIRANTES := {
	"market": [Vector2(101,266),Vector2(107,200),Vector2(140,173),Vector2(164,166),Vector2(151,148),Vector2(163,119),Vector2(182,101),Vector2(214,100),Vector2(229,120),Vector2(232,150),Vector2(217,169),Vector2(242,181),Vector2(273,253),Vector2(271,271)],
	"fruit_stall": [Vector2(511,266),Vector2(519,201),Vector2(539,167),Vector2(578,151),Vector2(578,142),Vector2(553,139),Vector2(551,124),Vector2(563,110),Vector2(578,100),Vector2(584,81),Vector2(612,79),Vector2(627,94),Vector2(651,96),Vector2(653,110),Vector2(632,134),Vector2(629,149),Vector2(659,162),Vector2(694,207),Vector2(702,248),Vector2(686,268)],
	"grain_stall": [Vector2(938,261),Vector2(936,209),Vector2(952,179),Vector2(976,169),Vector2(953,160),Vector2(948,132),Vector2(965,108),Vector2(984,93),Vector2(1013,93),Vector2(1032,108),Vector2(1032,147),Vector2(1020,163),Vector2(1048,170),Vector2(1071,198),Vector2(1081,239),Vector2(1045,264)],
	"dairy_stall": [Vector2(1302,263),Vector2(1321,215),Vector2(1355,169),Vector2(1394,152),Vector2(1367,149),Vector2(1360,132),Vector2(1371,114),Vector2(1391,100),Vector2(1401,83),Vector2(1425,80),Vector2(1440,91),Vector2(1465,92),Vector2(1479,105),Vector2(1476,120),Vector2(1451,140),Vector2(1448,157),Vector2(1478,165),Vector2(1523,207),Vector2(1554,241),Vector2(1579,260),Vector2(1577,272)]
}
var residents: Dictionary = {}
var merchants: Dictionary = {}
var shoppers: Array[Node2D] = []
var last_purchase: Array[int] = []
var animals: Dictionary = {}
var deed_label := Label.new()
var teacher: Node2D
var hut_exteriors: Array[Sprite2D] = []
var roofs: Dictionary = {}
var scenery_reservations: Array[Rect2] = []
var doorways: Dictionary = {}
var interiors: Dictionary = {}
var anchors: Dictionary = {}
var visuals: Dictionary = {}
var seed_groups: Array[Node2D] = []
var plants: Array[Sprite2D] = []
var beds: Array[Sprite2D] = []
var soil_layer := Node2D.new()
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
	if key == "home":
		var foundation := Sprite2D.new()
		foundation.texture = preload("res://assets/home_contact.png")
		foundation.centered = false
		foundation.offset = Vector2(-tex.get_width()*0.5-16,-tex.get_height()-16)
		foundation.scale = Vector2.ONE * height / tex.get_height()
		node.add_child(foundation)
	elif art.textures.has(key+"_contact"):
		var shade: Sprite2D = art.sprite(key+"_contact",height*0.5)
		shade.position = pos + Vector2(0,height*0.16)
		soil_layer.add_child(shade)
	else:
		node.add_child(art.ground_shadow(sprite_width*0.98,maxf(8,height*0.25)))
	var illustration: Sprite2D = art.sprite(key,height)
	node.add_child(illustration)
	if key == "village_hut":
		hut_exteriors.append(illustration)
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
	var walls := [[Vector2(0,-65),extent,14 if key == "school" else 68],[Vector2(-extent+5,0),5,66],[Vector2(extent-5,0),5,66],
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

func inside_building(key: String, viewer: Vector2) -> bool:
	var relative: Vector2 = viewer - SITES[key][0]
	var doorway := absf(relative.x-float(doorways[key])) < 27 and relative.y <= 10
	return absf(relative.x) < float(SITES[key][3])-14 and relative.y >= -67 and (relative.y < -7 or doorway)

func reveal_rooms(viewer: Vector2, delta: float) -> void:
	for hut in hut_exteriors:
		var local_feet := viewer - hut.global_position
		var size := hut.texture.get_size()*hut.scale
		var covered := local_feet.y <= 0 and local_feet.y >= -size.y and absf(local_feet.x) < size.x*0.47
		hut.self_modulate.a = move_toward(hut.self_modulate.a,0.32 if covered else 1.0,delta*5)
	for key: String in roofs:
		var inside := inside_building(key,viewer)
		var relative: Vector2 = viewer - SITES[key][0]
		var texture: Texture2D = art.textures[key]
		var height: float = SITES[key][2]
		var half_width := height * texture.get_width() / texture.get_height() * 0.5
		var behind := relative.y <= 0 and relative.y >= -height and absf(relative.x) <= half_width+9
		var roof: Node2D = roofs[key]
		var opacity := 0.0 if inside else (0.4 if behind else 1.0)
		roof.modulate.a = move_toward(roof.modulate.a,opacity,delta*5)
		interiors[key].visible = inside
	teacher.visible = interiors.school.visible

func build(root: Node2D, atlas: RefCounted) -> void:
	art = atlas
	var ground := Sprite2D.new()
	ground.texture = preload("res://assets/ground.webp")
	ground.centered = false
	ground.scale = Vector2(1536,1024)/ground.texture.get_size()
	root.add_child(ground)
	var clearing := Sprite2D.new()
	clearing.texture = preload("res://assets/clearing.webp")
	clearing.centered = false
	clearing.position.x = 1408
	clearing.scale = Vector2(1152,1024)/clearing.texture.get_size()
	root.add_child(clearing)
	var south := Sprite2D.new()
	south.texture = preload("res://assets/baixada.webp")
	south.centered = false
	south.position.y = 896
	south.scale = Vector2(2560,768)/south.texture.get_size()
	root.add_child(south)
	var lane := Polygon2D.new()
	lane.position = Vector2(980,330)
	lane.polygon = PackedVector2Array([Vector2.ZERO,Vector2(740,0),Vector2(740,740),Vector2(0,740)])
	var paint := ShaderMaterial.new()
	paint.shader = preload("res://systems/lane.gdshader")
	paint.set_shader_parameter("earth",ground.texture)
	lane.material = paint
	root.add_child(lane)
	root.add_child(soil_layer)
	var worked_ground := Sprite2D.new()
	worked_ground.texture = preload("res://assets/garden_ground.webp")
	worked_ground.centered = false
	worked_ground.position = Vector2(390,598)
	worked_ground.scale = Vector2.ONE*0.5
	soil_layer.add_child(worked_ground)
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
	teacher = Node2D.new()
	teacher.position = SITES.school[0] + Vector2(77,-45)
	display.add_child(teacher)
	teacher.add_child(art.ground_shadow(32,10))
	teacher.add_child(art.sprite("teacher",88))
	obstacle(teacher,8,7)
	teacher.visible = false
	anchors["teacher"] = teacher.position + Vector2(0,13)
	for detail: Array in [
		["geranium",Vector2(282,387),34,11], ["geranium",Vector2(1310,323),29,9],
		
		["granite",Vector2(796,707),39,15], ["granite",Vector2(144,805),57,22],
		["geranium",Vector2(1060,726),32,10],
		["granite",Vector2(1318,564),48,19], ["geranium",Vector2(1380,804),38,12]]:
		place(detail[0],detail[1],detail[2],detail[3])
	fenceline(Vector2(423,783),3)
	fenceline(Vector2(1088,363),2)
	for i in range(12):
		var pos := Vector2(460 + (i%4)*90,646 + floori(i/4.0)*83)
		if i >= 8: pos = Vector2(420+(i-8)*90,1358)
		anchors["plot%d" % i] = pos
		var base := Node2D.new()
		base.position = pos
		display.add_child(base)
		var bed: Sprite2D = art.sprite("dry_bed",36)
		bed.position = pos + Vector2(0,5)
		soil_layer.add_child(bed)
		obstacle(base,32,24)
		var seeds := Node2D.new()
		seeds.name = "Seeds"
		base.add_child(seeds)
		seed_groups.append(seeds)
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
	for side in [70,2510]:
		for i in range(6):
			plant_tree("mango" if i%2==0 else "banana",Vector2(side+rng.randf_range(-20,20),330+i*120),rng.randf_range(138,199),15)
	for pos in [Vector2(230,455),Vector2(1113,370),Vector2(1090,833),Vector2(278,809)]:
		plant_tree("banana",pos,113,12)

	build_orchard()
	build_fair()

func fenceline(start: Vector2, spans: int) -> void:
	var fence := preload("res://systems/fenceline.gd").new()
	fence.position = start
	fence.spans = spans
	fence.seed_value = int(start.x)
	display.add_child(fence)

func build_fair() -> void:
	for site: Array in [
		["market","food_booth",Vector2(1150,1245),3,["angu","bread","beiju"]],
		["fruit_stall","fruit_booth",Vector2(1345,1198),0,["pequi_fruit","lime_fruit","acerola_fruit"]],
		["grain_stall","grain_booth",Vector2(1542,1206),1,["ear","flour","roots"]],
		["dairy_stall","dairy_booth",Vector2(1735,1248),2,["milk","eggs","milk"]]]:
		var key: String = site[0]
		var stand := preload("res://systems/market_booth.gd").new()
		stand.position = site[2]
		display.add_child(stand)
		stand.setup(art,site[1],site[4])
		obstacle(stand,45,23)
		var seller := CharacterBody2D.new()
		seller.name = Farm.STALL_NAMES[key].get_slice(" · ",0)
		seller.position = stand.position-Vector2(0,1)
		display.add_child(seller)
		var figure := Polygon2D.new()
		var source: AtlasTexture = art.textures[site[1]]
		var cut := PackedVector2Array(FEIRANTES[key])
		figure.texture = source.atlas
		figure.uv = cut
		var center_x := source.region.get_center().x
		for i in cut.size():
			cut[i] = (cut[i]-Vector2(center_x,272))*0.31-Vector2(0,36)
		figure.polygon = cut
		seller.add_child(figure)
		merchants[key] = seller
		visuals[key] = seller
		anchors[key] = stand.position+Vector2(0,15)
	visuals.homestead = place("board",Vector2(805,1314),63,22)
	anchors.homestead = visuals.homestead.position+Vector2(0,18)
	deed_label.position = Vector2(-32,-56)
	deed_label.size = Vector2(64,32)
	deed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	deed_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	deed_label.add_theme_font_size_override("font_size",10)
	deed_label.add_theme_color_override("font_color",Color("#ffebbb"))
	visuals.homestead.add_child(deed_label)
	place("coop",Vector2(592,1482),92,38)
	for site: Array in [["farm_cat",Vector2(785,1460),33],["farm_hen",Vector2(627,1510),36],["farm_pig",Vector2(413,1502),51]]:
		var key: String = site[0]
		animals[key] = place(key,site[1],site[2])
		anchors[key] = site[1]+Vector2(0,12)
		place("basket",site[1]+Vector2(-24,0),20)
	fenceline(Vector2(335,1562),4)
	fenceline(Vector2(642,1565),5)
	for x in [1030,1840]: place("geranium",Vector2(x,1260),38,10)
	for i in 5:
		var actor := preload("res://systems/actor.gd").new()
		display.add_child(actor)
		actor.setup(art)
		actor.appearance = i%4
		shoppers.append(actor)
		last_purchase.append(-1)

func update_fair(farm: RefCounted, dt: float, viewer: Vector2, sound: RefCounted) -> void:
	for key: String in animals:
		var animal: Node2D = animals[key]
		animal.visible = farm.state.stock.has(key)
		if animal.visible:
			var elapsed: float = farm.state.time + float(Farm.STOCK_PRICE[key])
			var pace := sin(elapsed*0.5)
			var portrait := animal.get_child(1) as Sprite2D
			portrait.flip_h = cos(elapsed*0.5) < 0.0
			animal.position = anchors[key]-Vector2(0,12) + Vector2(8*pace,1.2*absf(sin(elapsed*3)))
	for i in shoppers.size():
		# Compartilhado pelo relógio da vila. Há tempo para chegar, comprar e sair pela frente.
		var clock: float = farm.state.time+i*9.7
		var leg := floori(clock/9.0)%6
		var sequence := [0,1,2,3,2,1]
		var start: Vector2 = anchors[BOOTHS[sequence[leg]]]
		var end: Vector2 = anchors[BOOTHS[sequence[(leg+1)%6]]]
		var phase := fmod(clock,9.0)
		var t := clampf((phase-2.5)/6.5,0,1)
		var offset := Vector2((i-2)*9,16+sin(t*PI)*(32+i*6))
		var shopper = shoppers[i]
		var pos := start.lerp(end,t)+offset
		var motion := (pos-Vector2(shopper.position))/maxf(dt,0.001)
		shopper.position = pos
		var purchase := floori(clock/9.0)
		if phase >= 1.1 and last_purchase[i] != purchase:
			if last_purchase[i] >= 0 and phase < 1.6 and pos.distance_to(viewer) < 290:
				sound.play(display,pos,"coin",-23)
			last_purchase[i] = purchase
		var items := ["Angu","Manga","Milho","Ovos"]
		shopper.pose(motion.limit_length(70),dt,items[sequence[leg]] if phase>1.1 else "")


func build_orchard() -> void:
	for site: Array in [
		["pequi_tree",Vector2(1572,467),204,20], ["lime_tree",Vector2(1785,400),157,17],
		["acerola_tree",Vector2(1822,668),134,14],
		["village_hut",Vector2(2115,350),173,78], ["village_hut",Vector2(2382,419),187,86],
		["village_hut",Vector2(2268,722),155,68]]:
		place(site[0],site[1],site[2],site[3])
	for site: Array in [
		["gardener",Vector2(1992,452)], ["weaver",Vector2(2104,559)],
		["cook",Vector2(2222,669)], ["healer",Vector2(2342,481)]]:
		var key: String = site[0]
		visuals[key] = place(key,site[1],88,10)
		for child: Node in visuals[key].get_children():
			if child is Sprite2D and child.texture == art.textures[key]: residents[key] = child
		anchors[key] = site[1]+Vector2(0,14)
	var spots := {"pequi_drop":Vector2(1614,489),"lime_drop":Vector2(1821,422),"acerola_drop":Vector2(1857,688)}
	for key: String in spots:
		var shade: Sprite2D = art.ground_shadow(18,7)
		shade.position = spots[key]-Vector2(0,2)
		soil_layer.add_child(shade)
		fruit_shadows[key] = shade
		var fruit: Sprite2D = art.sprite(key,12 if key == "acerola_drop" else 15)
		fruit.modulate = Color("#e5d5ba")
		display.add_child(fruit)
		dropped[key] = fruit
		anchors[key] = spots[key]
	for i in 10:
		plant_tree("mango" if i%2 else "banana",Vector2(1515+i*99,142+13*sin(i)),147+8*(i%4),15)

func update_fruits(farm: RefCounted) -> void:
	for key: String in dropped:
		var remaining: float = farm.state.fallen[key]-farm.state.time
		var fruit: Node2D = dropped[key]
		fruit.visible = remaining < 0.45
		fruit_shadows[key].visible = fruit.visible
		var t := clampf(remaining/0.45,0.0,1.0)
		fruit.position = anchors[key] - Vector2(21*t,62*t*(2.0-t))


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
		if key == "teacher" and not inside_building("school",pos): continue
		var dist := pos.distance_to(anchors[key])
		if dropped.has(key) and dist > 32: continue
		if dist < best:
			best = dist
			target = key
	return target

func refresh(farm: RefCounted) -> void:
	deed_label.text = "SÍTIO DA VILA" if farm.state.land else "VENDE-SE"
	for i in range(plants.size()):
		var p: Dictionary = farm.state.plots[i]
		var stage := int(p.stage)
		plants[i].visible = stage >= 2
		var surface: String = ["dry_bed","tilled_bed","tilled_bed","wet_bed","tilled_bed"][stage]
		var variation := (i + i/4) % 4
		beds[i].texture = art.textures[surface + (str(variation) if variation > 0 else "")]
		seed_groups[i].visible = stage == 2
		if stage < 2: continue
		var key: String = ["corn","cassava","rice","bean"][int(p.crop)]
		var height := 51.0
		if stage == 2: height = 12
		if stage == 3: height = 29
		if p.crop != 0 and stage < 4: key = ["seedling","rootbud","ricebud","beanbud"][int(p.crop)]
		if p.crop == 0 and stage < 4: key = "young" if stage == 3 else "seedling"
		art.paint(plants[i],key,height)

func face_speaker(key: String, where: Vector2) -> void:
	if residents.has(key):
		var portrait: Sprite2D = residents[key]
		portrait.flip_h = where.x < portrait.global_position.x
	elif merchants.has(key):
		var seller: Node2D = merchants[key]
		seller.get_child(0).scale.x = -1 if where.x < seller.position.x else 1
