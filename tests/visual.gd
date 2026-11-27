extends SceneTree

var village: Node
var failed := false

func _initialize() -> void:
	call_deferred("run")

func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_jpg("res://reports/"+name+".jpg",0.91)
	if result != OK: failed = true

func run() -> void:
	village = preload("res://scenes/village.tscn").instantiate()
	root.add_child(village)
	await create_timer(0.5).timeout
	# Ao anoitecer, qualquer avanço do relógio altera a cor do cenário.
	var original_time: float = village.farm.state.time
	village.farm.state.time = 380.0
	await create_timer(0.15).timeout
	for menu in ["caderno","baú","caderno"]:
		var before: Color = village.tint.color
		var clock: float = village.farm.state.time
		if menu == "caderno": village.hud.toggle()
		else: village.hud.open_tools()
		await create_timer(0.25).timeout
		if village.farm.state.time != clock or not village.tint.color.is_equal_approx(before): failed = true
		if menu == "caderno": village.hud.toggle()
		else: village.hud.close_tools()
		if village.hud.kit.visible or village.hud.page.visible or not village.hud.base.visible: failed = true
	village.farm.state.time = original_time
	var farmer: CharacterBody2D = village.actors[1]
	var corn: Vector2 = village.land.anchors["plot0"]
	farmer.position = corn+Vector2(0,22)
	for i in range(3):
		await create_timer(0.3).timeout
		if not village.perform(1,"plot0",i): failed = true
	village.farm.tick(16)
	village.land.refresh(village.farm)
	await create_timer(0.45).timeout
	await snap("horta")
	village.perform(1,"plot0",3)
	await create_timer(0.35).timeout
	if village.farm.hands.get(1) != "Milho": failed = true
	farmer.position = village.land.anchors["tray"]
	await create_timer(0.8).timeout
	await snap("cesto")
	if not village.perform(1,"tray"): failed = true
	await create_timer(0.8).timeout
	await snap("bandeja")
	if not village.perform(1,"tray"): failed = true
	await create_timer(0.8).timeout
	farmer.position = village.land.anchors["mill"]
	village.perform(1,"mill")
	await create_timer(0.35).timeout
	village.farm.tick(5)
	village.perform(1,"mill")
	await create_timer(0.35).timeout
	farmer.position = village.land.anchors["stove"]
	village.perform(1,"stove")
	village.farm.tick(7)
	await create_timer(0.35).timeout
	village.perform(1,"stove")
	await create_timer(0.35).timeout
	farmer.position = village.land.anchors["table"]
	village.perform(1,"table")
	await create_timer(0.8).timeout
	await snap("refeicao")
	farmer.position = village.land.SITES.home[0]-Vector2(0,40)
	await create_timer(0.7).timeout
	await snap("interior")
	farmer.position = village.land.SITES.school[0] + Vector2(0,70)
	await create_timer(0.8).timeout
	await snap("escola")
	farmer.position = village.land.SITES.school[0] + Vector2(0,-30)
	await create_timer(0.7).timeout
	await snap("sala_de_aula")
	village.hud.toggle()
	village.hud.tabs.current_tab = 1
	await snap("caderno")
	village.hud.tabs.current_tab = 3
	for i in 4:
		village.hud.cards[i].pressed.emit()
		if farmer.appearance != i or village.hud.spread_caption.text != village.hud.NAMES[i]: failed = true
	await snap("personagens")
	village.hud.sections.current_tab = 1
	village.hud.fullscreen.button_pressed = true
	await create_timer(0.3).timeout
	if root.mode != Window.MODE_FULLSCREEN or not village.hud.resolution.disabled: failed = true
	village.hud.fullscreen.button_pressed = false
	village.hud.resolution.select(0)
	village.hud.resolution.item_selected.emit(0)
	await create_timer(0.3).timeout
	if root.mode != Window.MODE_WINDOWED or root.size != Vector2i(960,540): failed = true
	await snap("tela")
	if village.farm.state.served != 1: failed = true
	print("Percurso gráfico: ","FALHOU" if failed else "OK")
	village.queue_free()
	await process_frame
	await create_timer(0.25).timeout
	quit(1 if failed else 0)
