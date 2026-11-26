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
	var farmer: CharacterBody2D = village.actors[1]
	var corn: Vector2 = village.land.anchors["plot0"]
	farmer.position = corn+Vector2(0,22)
	for i in range(3):
		await create_timer(0.3).timeout
		if not village.perform(1,"plot0"): failed = true
	village.farm.tick(16)
	village.land.refresh(village.farm)
	await create_timer(0.45).timeout
	await snap("horta")
	village.perform(1,"plot0")
	await create_timer(0.35).timeout
	if village.farm.hands.get(1) != "Milho": failed = true
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
	village.hud.toggle()
	await snap("caderno")
	if village.farm.state.served != 1: failed = true
	print("Percurso gráfico: ","FALHOU" if failed else "OK")
	village.queue_free()
	await process_frame
	await create_timer(0.25).timeout
	quit(1 if failed else 0)
