extends SceneTree

var world: Node
var until: int

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	world = preload("res://scenes/village.tscn").instantiate()
	root.add_child(world)
	var role: String = OS.get_cmdline_user_args()[1]
	world.hud.pin.text = "safra"
	until = Time.get_ticks_msec()+20000
	if role == "host":
		world.host_game()
		for cycle in range(2):
			while world.actors.size() < 2 and active(): await process_frame
			if world.actors.size() != 2: return fail("conexão")
			world.farm.state.sales = 9
			while world.actors.size() > 1 and active(): await process_frame
	else:
		world.hud.pin.text = "incorreta"
		world.join_game("127.0.0.1")
		while world.joining and active(): await process_frame
		if world.connected or not active(): return fail("senha recusada")
		world.hud.pin.text = "safra"
		for cycle in range(2):
			world.join_game("127.0.0.1")
			while (not world.connected or world.farm.state.sales != 9) and active(): await process_frame
			if not active(): return fail("estado compartilhado")
			world.leave_game()
			await create_timer(0.4).timeout
	print("Reconexão e sala privada: OK ",role)
	world.queue_free()
	await process_frame
	await create_timer(0.25).timeout
	quit()

func active() -> bool:
	return Time.get_ticks_msec() < until

func fail(message: String) -> void:
	printerr("FALHOU ",message)
	quit(1)
