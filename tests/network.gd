extends SceneTree

var game: Node
var count := 2
var role := ""
var start: int

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	role = args[1]
	count = int(args[2])
	game = preload("res://scenes/village.tscn").instantiate()
	root.add_child(game)
	start = Time.get_ticks_msec()
	if role == "host":
		game.host_game()
		while game.actors.size() != count and elapsed() < 22: await process_frame
		if game.actors.size() != count: return fail("participantes")
		if count == 4:
			if not await fifth_is_refused(): return fail("limite de quatro")
			print("Quinta conexão ENet recusada com quatro jogadores ativos.")
		for peer: int in game.actors:
			game.actors[peer].position = game.land.anchors["plot0"]
		var plot: Dictionary = game.farm.state.plots[0]
		plot.stage = 4
		while elapsed() < 24 and not game.farm.hands.values().has("Milho"): await process_frame
		if not game.farm.hands.values().has("Milho"): return fail("ação remota")
		if count == 4:
			for peer: int in game.actors:
				if peer == 1: continue
				game.actors[peer].position = game.land.anchors.fruit_stall
				if game.farm.hands.get(peer,"") == "": game.farm.hands[peer] = "Manga"
			game.dirty = true
			while game.farm.state.sales < 2 and elapsed() < 22: await process_frame
			if game.farm.state.coins != 6 or game.farm.state.sales != 2: return fail("duas vendas na feira")
		await create_timer(0.35).timeout
		for peer: int in game.actors:
			if peer != 1 and game.actors[peer].appearance != 3: return fail("personagem remoto")
		if game.farm.hands.values().count("Milho") != 1: return fail("colheita duplicada")
		while game.actors.size() != 1 and elapsed() < 25: await process_frame
		if game.farm.state.storage.count("Milho") != 1: return fail("carga na desconexão")
	else:
		game.hud.show_avatar(3)
		game.apply_settings()
		game.join_game("127.0.0.1")
		while elapsed() < 22 and (not game.connected or game.farm.state.plots[0].stage != 4): await process_frame
		if not game.connected or game.farm.state.plots[0].stage != 4: return fail("snapshot")
		game.request_action.rpc_id(1,"plot0",game.farm.prompt(game.multiplayer.get_unique_id(),"plot0"),3)
		if count == 4:
			var me: int = game.multiplayer.get_unique_id()
			while not (game.farm.hands.get(me,"") in ["Milho","Manga"]) and elapsed() < 22: await process_frame
			if game.farm.hands.get(me,"") == "Manga":
				await create_timer(0.35).timeout
				game.request_action.rpc_id(1,"fruit_stall",game.farm.prompt(me,"fruit_stall"),3)
			while game.farm.state.sales != 2 and elapsed() < 22: await process_frame
			if game.farm.state.coins != 6: return fail("saldo compartilhado")
		await create_timer(1.7).timeout
		if not game.farm.hands.values().has("Milho") and not game.farm.state.storage.has("Milho"): return fail("sincronização")
		game.leave_game()
	print("OK ",role," / ",count)
	game.queue_free()
	await process_frame
	await create_timer(0.25).timeout
	quit()

func elapsed() -> float:
	return (Time.get_ticks_msec()-start)/1000.0

func fail(message: String) -> void:
	printerr("FALHOU ",role," ",message)
	quit(1)

func fifth_is_refused() -> bool:
	var extra := ENetMultiplayerPeer.new()
	if extra.create_client("127.0.0.1",game.PORT) != OK: return false
	extra.get_peer(1).set_timeout(2,800,2500)
	var deadline := Time.get_ticks_msec()+6000
	while extra.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING and Time.get_ticks_msec() < deadline:
		extra.poll()
		await process_frame
	var rejected := extra.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED
	extra.close()
	return rejected and game.actors.size() == 4
