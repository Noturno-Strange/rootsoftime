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
	check(Save.write(farm),"Gravação")
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
