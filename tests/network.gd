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
		for peer: int in game.actors:
			game.actors[peer].position = game.land.anchors["plot0"]
		var plot: Dictionary = game.farm.state.plots[0]
		plot.stage = 4
		while elapsed() < 24 and not game.farm.hands.values().has("Milho"): await process_frame
		if not game.farm.hands.values().has("Milho"): return fail("ação remota")
		await create_timer(0.8).timeout
		if game.farm.hands.values().count("Milho") != 1: return fail("colheita duplicada")
		while game.actors.size() != 1 and elapsed() < 25: await process_frame
		if game.farm.state.storage.count("Milho") != 1: return fail("carga na desconexão")
	else:
		game.join_game("127.0.0.1")
		while elapsed() < 22 and (not game.connected or game.farm.state.plots[0].stage != 4): await process_frame
		if not game.connected or game.farm.state.plots[0].stage != 4: return fail("snapshot")
		game.request_action.rpc_id(1,"plot0",game.farm.prompt(game.multiplayer.get_unique_id(),"plot0"))
		await create_timer(1.7).timeout
		if not game.farm.hands.values().has("Milho"): return fail("sincronização")
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
