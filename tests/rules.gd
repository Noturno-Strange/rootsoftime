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
	var preview := Farm.new()
	preview.state.time = 590
	preview.hands[1] = "Pequi"
	village.hud.refresh(preview,1,"wash","E")
	check("Madrugada" in village.hud.objective.text and not "[E]" in village.hud.hint.text,"Madrugada e tanque com ingrediente incompatível")
	preview.hands[1] = "Mandioca"
	village.hud.refresh(preview,1,"wash","E")
	check("[E]" in village.hud.hint.text,"Tanque oferece preparo com mandioca")
	village.hud.refresh(preview,1,"plot8","E")
	check(not "[" in village.hud.hint.text,"Terreno fechado não sugere equipar ou usar ferramenta")
	var hut: Sprite2D = village.land.hut_exteriors[0]
	village.land.reveal_rooms(hut.global_position-Vector2(0,80),1)
	check(hut.self_modulate.a < 0.4,"Telhado revela a pessoa atrás da casa")
	village.land.reveal_rooms(hut.global_position+Vector2(0,20),1)
	check(is_equal_approx(hut.self_modulate.a,1.0),"Casa opaca ao sair de trás dela")
	var wheel := InputEventMouseButton.new()
	wheel.pressed = true
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	var initial_zoom: Vector2 = village.camera.zoom
	village._input(wheel)
	check(village.hud.tool_id == 3 and village.camera.zoom == initial_zoom,"Roda volta ao cesto")
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	village._input(wheel)
	check(village.hud.tool_id == 0,"Roda avança à enxada")
	wheel.ctrl_pressed = true
	village._input(wheel)
	check(village.hud.tool_id == 0 and village.camera.zoom.x < initial_zoom.x,"Ctrl e roda ajustam zoom")
	village.camera.zoom = initial_zoom
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
	var school: Vector2 = village.land.SITES.school[0]
	var rear := school + Vector2(-183,-108)
	for dir in [1,-1]:
		var start := rear if dir == 1 else rear + Vector2(366,0)
		check(village.land.BOUNDS.has_point(start) and not player.test_move(Transform2D(0,start),Vector2(366*dir,0)), "Travessia física atrás da escola")
	village.land.reveal_rooms(rear+Vector2(183,0),1)
	check(not village.land.teacher.visible and not village.land.interiors.school.visible, "Passagem externa preserva a sala fechada")
	var desk: Vector2 = village.land.anchors.teacher
	player.position = desk
	village.land.reveal_rooms(desk,1)
	check(village.land.teacher.visible and village.land.nearest(desk) == "teacher", "Professora acessível dentro da sala")
	check(village.perform(1,"teacher") and "Célia" in village.hud.news.text, "Conversa na escola")
	player.position = Vector2(desk.x,school.y+14)
	check(not village.perform(1,"teacher") and village.land.nearest(player.position) != "teacher", "Sem conversa através da parede")
	var class_farm := Farm.new()
	class_farm.state.family = "school"
	class_farm.state.bell = 24
	check("24 s" in class_farm.act(1,"teacher"), "Professora informa tempo de aula")
	class_farm.tick(24)
	check("terminou" in class_farm.act(1,"teacher") and class_farm.state.family == "school", "Professora avisa da saída sem concluir a escolta")
	player.position = village.land.SPAWN
	var grove := Farm.new()
	check(not grove.act(1,"pequi_drop").is_empty() and grove.act(2,"pequi_drop").is_empty(),"Fruto caído tem retirada exclusiva")
	grove.tick(33)
	check(not grove.act(2,"pequi_drop").is_empty(),"Novo pequi cai após intervalo")
	for i in Farm.HARVEST_LIMIT:
		grove.hands[2] = ""
		grove.tick(33)
		grove.act(2,"lime_drop")
	check(grove.unwell(2) and not grove.unwell(1),"Mal-estar individual após esforço")
	check(not grove.act(2,"healer").is_empty() and not grove.unwell(2),"Cuidados do pajé restauram disposição")
	grove.state.effort[1] = Farm.HARVEST_LIMIT-1
	grove.hands[1] = ""
	grove.state.plots[0].stage = 4
	grove.act(1,"plot0")
	check(grove.sore(1) and not grove.sore(2),"Dor muscular na colheita do canteiro")
	grove.act(1,"healer")
	check(not grove.unwell(1),"Recuperação da dor muscular")
	check_workshop()
	check_south()
	check_rain_and_market()
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
	check(farm.state.coins == 24 and farm.act(1,"market") != "" and farm.state.upgrade,"Banco restaurado")
	farm.act(1,"hen")
	farm.act(1,"mix")
	farm.hands[2] = "Fubá"
	check(farm.act(2,"mix") != "" and farm.hands[2] == "Massa de broa","Mistura compartilhada")
	var old_save := farm.state.duplicate(true)
	old_save.plots.resize(8)
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
	await create_timer(0.7).timeout
	village.queue_free()
	await process_frame
	await create_timer(0.25).timeout
	quit(1 if failures else 0)

# Reproduz as ações disponíveis na vila, sempre com um único cesto.
func make_product(farm: Farm, product: String) -> bool:
	if product in Farm.CROPS:
		var key := "plot%d" % Farm.CROPS.find(product)
		if farm.state.water == 0: farm.act(1,"well",2)
		for step in 3:
			if farm.required_tool(key) != step or farm.act(1,key).is_empty(): return false
		farm.tick(25)
		return farm.required_tool(key) == 3 and not farm.act(1,key).is_empty() and farm.hands[1] == product
	var sources := {"Leite":"cow","Ovos":"hen","Manga":"orchard"}
	for spot: String in Farm.FRUIT_SPOTS:
		if Farm.FRUIT_SPOTS[spot] == product:
			farm.tick(33)
			return not farm.act(1,spot).is_empty() and farm.hands[1] == product
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
	for size in [1,2,4]:
		var market := Farm.new()
		market.participants = size
		for dish: String in Farm.ORDERS:
			var quota := int(market.state.quota)
			for unit in quota:
				check(make_product(market,dish) and not market.act(1,"market").is_empty(),"Entregar "+dish)
		check(market.state.feasts == 1,"Festa após ciclo de encomendas")
		check(not market.act(1,"market").is_empty() and market.state.upgrade,"Restaurar banco com as vendas")

func check_workshop() -> void:
	var farm := Farm.new()
	check(farm.act(1,"warehouse",0).is_empty(),"Melhoria exige moedas")
	farm.state.coins = 140
	for tool in 4:
		for level in [2,3]:
			check(not farm.act(1,"warehouse",tool).is_empty() and farm.state.levels[tool] == level,"Comprar nível %d" % level)
		check(farm.act(1,"warehouse",tool).is_empty(),"Limite de três níveis")
	check(farm.state.coins == 0,"Custo das melhorias")
	farm.state.water = 0
	farm.act(1,"plot0")
	farm.act(1,"plot0")
	check(farm.state.plots[2].stage == 2 and farm.act(1,"plot0").is_empty(),"Fileira plantada precisa de água")
	check(not farm.act(2,"well",2).is_empty() and farm.state.water == 6,"Abastecimento no poço")
	check(not farm.act(1,"plot0").is_empty() and farm.state.water == 5,"Consumo na rega")
	farm.tick(25)
	farm.act(1,"plot0")
	check(farm.state.storage.size() == 2,"Colheita extra no depósito")

func check_rain_and_market() -> void:
	var farm := Farm.new()
	farm.state.plots[0].stage = 2
	farm.tick(180)
	check(farm.state.plots[0].stage == 2, "Sementes aguardam água no tempo seco")
	var single_tick := Farm.new()
	single_tick.state = farm.state.duplicate(true)
	farm.tick(1)
	check(farm.state.plots[0].stage == 3 and farm.state.water == 2, "Chuva irriga sem consumir água")
	farm.tick(60)
	single_tick.tick(61)
	check(farm.state.plots == single_tick.state.plots and farm.state.plots[0].stage == 4, "Chuva e crescimento independem do tamanho do tick")
	farm.state.quota = 2
	for id in [1,2]:
		farm.hands[id] = "Angu"
		var payout := farm.market_payout("Angu")
		var before: int = farm.state.coins
		check(str(payout) in farm.prompt(id,"market"), "Preço indicado na feira")
		var receipt := farm.act(id,"market")
		check(("parcial" in receipt) == (id == 1), "Comprovante de entrega parcial ou completa")
		check(farm.state.coins == before + payout, "Feira paga o preço anunciado")
	check(farm.state.coins == 17 and farm.state.order == 1, "Bônus único na última entrega")
	check(farm.sale_price("Beiju") > farm.sale_price("Arroz branco") and farm.sale_price("Milho") == 0, "Valor artesanal e ingredientes crus")
	farm.hands[1] = "Beiju"
	check("Venda na feira" in farm.act(1,"market") and farm.state.delivered == 0, "Venda avulsa preserva encomenda")

func check_south() -> void:
	var farm := Farm.new()
	check(farm.act(1,"homestead").is_empty() and farm.act(2,"plot8").is_empty(),"Sítio fechado sem compra")
	farm.state.coins = 60
	check(not farm.act(1,"homestead").is_empty() and farm.act(2,"homestead").is_empty() and farm.state.coins == 25,"Compra única compartilhada")
	check(not farm.act(2,"plot8").is_empty(),"Canteiro novo acessível")
	for animal: String in Farm.STOCK_PRICE:
		check(not farm.act(1,animal).is_empty(),"Criação de "+animal)
	check(farm.state.coins == 0,"Preço de terreno e animais")
	farm.hands[2] = "Milho"
	farm.act(2,"farm_hen")
	check(farm.hands[2] == "Ovos" and farm.act(1,"farm_hen").is_empty(),"Milho por ovos com descanso")
	check(farm.act(2,"fruit_stall").is_empty() and not farm.act(2,"dairy_stall").is_empty() and farm.state.coins == 4,"Comprador especializado em laticínios e ovos")
	farm.hands[2] = "Feijão"
	farm.act(2,"farm_pig")
	farm.state.plots[8].stage = 3
	check(farm.hands[2] == "Adubo" and not farm.act(2,"plot8").is_empty() and farm.state.plots[8].stage == 4,"Adubo do chiqueiro na plantação nova")
	farm.state.effort[2] = Farm.HARVEST_LIMIT
	farm.act(2,"farm_cat")
	check(not farm.unwell(2),"Cuidado do gato recupera disposição")
	check(Save.valid(farm.state.duplicate(true),Farm.new().state),"Criação e terreno persistem")
	for stall: String in Farm.OFFERS:
		for item: String in Farm.OFFERS[stall]:
			farm.hands[1] = item
			check(not farm.act(1,stall).is_empty() and farm.hands[1] == "","Vender "+item)
