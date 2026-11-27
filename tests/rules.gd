extends SceneTree
const Farm = preload("res://systems/farm.gd")
const Save = preload("res://systems/save.gd")
var failures := 0
var checks := 0

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FALHOU: ",title)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var village := preload("res://scenes/village.tscn").instantiate()
	root.add_child(village)
	await physics_frame
	check(village.kids.size() == 4,"Quatro crianças")
	for goal: Vector2 in village.play_points:
		check(not village.paths.route(village.land.CHILD_HOME,goal).is_empty(),"Trilha de brincadeira")
	var player: CharacterBody2D = village.actors[1]
	for name: String in ["home","school"]:
		var center: Vector2 = village.land.SITES[name][0]
		var door: float = village.land.doorways[name]
		for side in [-78,78]:
			var start := Transform2D(0,center+Vector2(side,30))
			check(player.test_move(start,Vector2(0,-48)),"Parede frontal "+name)
		check(not player.test_move(Transform2D(0,center+Vector2(door,30)),Vector2(0,-60)),"Porta livre "+name)
		check(player.test_move(Transform2D(0,center+Vector2(door,-31)),Vector2(0,-65)),"Limite do piso "+name)
	check_progression()
	var farm: Farm = village.farm
	for k: String in village.land.anchors:
		var path: PackedVector2Array = village.paths.route(village.land.SPAWN,village.land.anchors[k])
		check(not path.is_empty() and path[-1].distance_to(village.land.anchors[k]) < 65,"Acesso: "+k)
	check(not village.perform(1,"school"),"Distância validada")
	for i in range(3):
		check(farm.act(1,"plot0") != "","Etapa de cultivo %d" % i)
	check(farm.act(1,"plot0") == "","Colheita precoce")
	farm.tick(15)
	check(farm.act(1,"plot0") != "" and farm.hands[1] == "Milho","Colheita")
	farm.act(2,"plot0")
	check(farm.hands.get(2,"") == "","Colheita exclusiva")
	check(farm.act(1,"mill") != "","Moagem")
	check(farm.act(2,"mill") == "","Trava do moinho")
	farm.tick(8)
	check(farm.act(2,"mill") != "" and farm.act(1,"mill") == "","Retirada única")
	check(farm.act(2,"stove") != "","Cozimento")
	farm.tick(8)
	farm.act(1,"stove")
	check(farm.hands[1] == "Angu","Angu pronto")
	check(farm.act(1,"table") != "" and farm.state.served == 1,"Servir refeição")
	farm.tick(5)
	check(farm.act(1,"home") != "" and farm.act(1,"school") != "","Ida à escola")
	check(farm.act(2,"school") == "","Aula em andamento")
	farm.tick(25)
	check(farm.act(2,"school") != "","Buscar após aula")
	farm.release(2)
	check(farm.state.family == "school","Recuperação após desconexão")
	farm.act(1,"school")
	check(farm.act(1,"home") != "" and farm.state.trips == 1,"Chegada em casa")
	for i in range(3): farm.act(1,"plot1")
	farm.tick(22)
	farm.act(1,"plot1")
	for k: String in ["wash","grater","press","sieve","stove"]:
		check(farm.act(1,k) != "","Iniciar "+k)
		farm.tick(10)
		check(farm.act(1,k) != "","Finalizar "+k)
	check(farm.hands[1] == "Farinha de mandioca","Cadeia da mandioca")
	farm.act(1,"storage")
	farm.act(2,"storage")
	farm.release(2)
	check(farm.state.storage == ["Farinha de mandioca"],"Depósito e desconexão")
	for i in range(3):
		farm.hands[1] = "Angu"
		farm.act(1,"market")
	check(farm.state.coins == 18 and farm.act(1,"market") != "" and farm.state.upgrade,"Banco restaurado")
	farm.act(1,"hen")
	farm.act(1,"mix")
	farm.hands[2] = "Fubá"
	check(farm.act(2,"mix") != "" and farm.hands[2] == "Massa de broa","Mistura compartilhada")
	var old_save := farm.state.duplicate(true)
	old_save.version = 1
	old_save.erase("served_item")
	old_save.erase("tray")
	check(Save.valid(old_save,Farm.new().state) and old_save.tray.is_empty(),"Migração da bandeja")
	for item: String in ["Milho","Manga","Ovos","Leite"]:
		farm.hands[9] = item
		check(farm.act(9,"tray") != "" and farm.hands[9] == "","Posicionar "+item)
	farm.hands[9] = "Arroz"
	check(farm.act(9,"tray") == "" and farm.hands[9] == "Arroz","Preservar carga com bandeja cheia")
	check(farm.act(8,"tray") != "" and farm.hands[8] == "Leite" and farm.state.tray.size() == 3,"Retirada compartilhada")
	for station: Dictionary in farm.recipes.values():
		for ingredient: String in station:
			check(farm.ICON.has(ingredient) and farm.ICON.has(station[ingredient][0]),"Ícones de "+ingredient)
	check(Save.write(farm),"Gravação")
	check(Save.recover(Farm.new().state).tray == farm.state.tray,"Posições preservadas no salvamento")
	check(Save.write(farm),"Backup")
	check(Save.recover(Farm.new().state).storage.has("Massa de broa"),"Carga preservada")
	var file := FileAccess.open(Save.PATH,FileAccess.WRITE)
	file.store_var({"version":0})
	file.close()
	check(Save.recover(Farm.new().state).upgrade,"Recuperação pelo backup")
	for atlas: Texture2D in village.art.textures.values():
		check(atlas.get_width() > 0 and atlas.get_height() > 0,"Região do atlas")
	print("%d verificações, %d falhas." % [checks,failures])
	village.queue_free()
	await process_frame
	await create_timer(0.25).timeout
	quit(1 if failures else 0)

# Reproduz as ações disponíveis na vila, sempre com um único cesto.
func make_product(farm: Farm, product: String) -> bool:
	if product in Farm.CROPS:
		var key := "plot%d" % Farm.CROPS.find(product)
		for step in 3:
			if farm.required_tool(key) != step or farm.act(1,key).is_empty(): return false
		farm.tick(25)
		return farm.required_tool(key) == 3 and not farm.act(1,key).is_empty() and farm.hands[1] == product
	var sources := {"Leite":"cow","Ovos":"hen","Manga":"orchard"}
	if sources.has(product):
		farm.tick(40)
		return not farm.act(1,sources[product]).is_empty() and farm.hands[1] == product
	for pair: String in Farm.BLENDS:
		if Farm.BLENDS[pair] != product: continue
		for ingredient in pair.split("|"):
			if not make_product(farm,ingredient) or farm.act(1,"mix").is_empty(): return false
		return farm.hands[1] == product
	for station: String in farm.recipes:
		for ingredient: String in farm.recipes[station]:
			var recipe: Array = farm.recipes[station][ingredient]
			if recipe[0] != product: continue
			if not make_product(farm,ingredient) or farm.act(1,station).is_empty(): return false
			farm.tick(float(recipe[1])+0.1)
			return not farm.act(1,station).is_empty() and farm.hands[1] == product
	return false

func check_progression() -> void:
	for dish: String in Farm.MEALS:
		var kitchen := Farm.new()
		check(make_product(kitchen,dish) and not kitchen.act(1,"table").is_empty(),"Preparar e servir "+dish)
	for size in [1,2,6]:
		var market := Farm.new()
		market.participants = size
		for dish: String in Farm.ORDERS:
			var quota := int(market.state.quota)
			for unit in quota:
				check(make_product(market,dish) and not market.act(1,"market").is_empty(),"Entregar "+dish)
		check(market.state.feasts == 1,"Festa após ciclo de encomendas")
		check(not market.act(1,"market").is_empty() and market.state.upgrade,"Restaurar banco com as vendas")
