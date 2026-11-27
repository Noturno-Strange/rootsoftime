extends Node2D

const Farm = preload("res://systems/farm.gd")
const Layout = preload("res://systems/placement.gd")
const Actor = preload("res://systems/actor.gd")
const Save = preload("res://systems/save.gd")
const Journal = preload("res://ui/journal.gd")
const PORT := 31842
var farm := Farm.new()
var land := Layout.new()
var art := preload("res://systems/art.gd").new()
var sound := preload("res://systems/sound.gd").new()
var hud := Journal.new()
var actors: Dictionary = {}
var directions: Dictionary = {}
var destinations: Dictionary = {}
var weather := preload("res://systems/weather.gd").new()
var chat_times: Dictionary = {}
var chat_history := PackedStringArray()
var last_actions: Dictionary = {}
var camera := Camera2D.new()
var kids: Array[Actor] = []
var routes := {}
var deadlines := {}
var play_points := [Vector2(520,585),Vector2(830,545),Vector2(1150,445),Vector2(1540,550),Vector2(1750,710)]
var tint := CanvasModulate.new()
var paths := preload("res://systems/paths.gd").new()
var target := ""
var highlight := Line2D.new()
var interact_key := KEY_E
var rebinding := false
var room_secret := ""
var state_timer := 0.0
var dirty := true
var net_timer := 0.0
var save_timer := 0.0
var foot_distance := 0.0
var last_foot := Vector2.ZERO
var birds := 2.0
var connected := false
var joining := false
var online := false
var family_prev := ""
var child_targets := PackedVector2Array()
var indicators: Dictionary = {}
var bench: Node2D
var settings := ConfigFile.new()
var test_mode := false

func _ready() -> void:
	test_mode = "--test" in OS.get_cmdline_user_args()
	if not test_mode: farm.state = Save.recover(farm.state)
	var session := multiplayer as SceneMultiplayer
	session.server_relay = false
	session.auth_callback = authenticate
	session.peer_authenticating.connect(begin_auth)
	session.peer_authentication_failed.connect(auth_failed)
	land.build(self,art)
	paths.build(land)
	add_child(tint)
	bench = land.place("bench",Vector2(930,542),43)
	var stations: Array = farm.recipes.keys()
	stations.append("table")
	for k: String in stations:
		var s: Sprite2D = art.sprite("meal",24)
		s.position = Vector2(12,-34)
		land.visuals[k].add_child(s)
		indicators[k] = s
	for i in range(4):
		var kid := Actor.new()
		land.display.add_child(kid)
		kid.setup(art,true)
		kid.kid_index = i
		kid.position = play_points[i]
		kids.append(kid)
	add_child(camera)
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 2048
	camera.limit_bottom = 1024
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8
	camera.zoom = Vector2.ONE * 1.32
	camera.offset = Vector2.ZERO
	var ear := AudioListener2D.new()
	camera.add_child(ear)
	ear.make_current()
	add_child(highlight)
	highlight.width = 2.5
	highlight.default_color = Color("#fff0b2")
	for i in range(33):
		var a := TAU*i/32.0
		highlight.add_point(Vector2(cos(a)*25,sin(a)*8))
	add_child(preload("res://systems/ambience.gd").new())
	add_child(weather)
	add_child(hud)
	hud.chat_requested.connect(chat_submit)
	hud.host_requested.connect(host_game)
	hud.join_requested.connect(join_game)
	hud.leave_requested.connect(leave_game)
	hud.remap_requested.connect(func() -> void:
		rebinding = true
		hud.info.text = "Pressione a nova tecla de interação.")
	hud.settings_changed.connect(apply_settings)
	settings.load("user://opcoes.cfg")
	interact_key = int(settings.get_value("input","interact",KEY_E))
	hud.quiet.set_pressed_no_signal(settings.get_value("audio","mute",false))
	hud.steady.set_pressed_no_signal(settings.get_value("camera","steady",false))
	for bus: String in hud.levels:
		hud.levels[bus].set_value_no_signal(settings.get_value("mix",bus,0.8))
	hud.farmer.set_pressed_no_signal(settings.get_value("avatar","female",false))
	apply_settings()
	multiplayer.peer_connected.connect(peer_in)
	multiplayer.peer_disconnected.connect(peer_out)
	multiplayer.connected_to_server.connect(joined)
	multiplayer.connection_failed.connect(failed)
	multiplayer.server_disconnected.connect(failed)
	spawn(1)
	camera.position = Layout.SPAWN
	camera.reset_smoothing()
	hud.net_status("Individual · Cooperativo para até seis pessoas",false)
	hud.status("Horta comunitária · aproxime-se de um canteiro")
	land.refresh(farm)

func apply_settings() -> void:
	camera.position_smoothing_enabled = not hud.steady.button_pressed
	AudioServer.set_bus_mute(0,hud.quiet.button_pressed)
	for bus: String in hud.levels:
		var level: float = hud.levels[bus].value
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus),linear_to_db(maxf(level,0.0001)))
		settings.set_value("mix",bus,level)
	settings.set_value("avatar","female",hud.farmer.button_pressed)
	if connected: choose_farmer.rpc_id(1,hud.farmer.button_pressed)
	elif actors.has(1): actors[1].female = hud.farmer.button_pressed
	settings.set_value("camera","steady",hud.steady.button_pressed)
	settings.set_value("audio","mute",hud.quiet.button_pressed)
	settings.set_value("input","interact",interact_key)
	if not test_mode: settings.save("user://opcoes.cfg")

func spawn(id: int) -> void:
	if actors.has(id): return
	var actor := Actor.new()
	land.display.add_child(actor)
	actor.setup(art)
	actor.position = Layout.SPAWN + Vector2(actors.size()*14,0)
	actor.female = hud.farmer.button_pressed if id == 1 and not connected else false
	actors[id] = actor
	directions[id] = Vector2.ZERO

func remove_actor(id: int) -> void:
	if actors.has(id):
		actors[id].queue_free()
		actors.erase(id)
	directions.erase(id)
	destinations.erase(id)
	last_actions.erase(id)

func begin_auth(id: int) -> void:
	if not multiplayer.is_server():
		(multiplayer as SceneMultiplayer).send_auth(id,room_secret.to_utf8_buffer())

func authenticate(id: int, payload: PackedByteArray) -> void:
	var session := multiplayer as SceneMultiplayer
	if multiplayer.is_server():
		if payload != room_secret.to_utf8_buffer():
			session.send_auth(id,PackedByteArray([0]))
			return
		session.send_auth(id,PackedByteArray([1]))
	elif payload != PackedByteArray([1]):
		call_deferred("failed")
		return
	session.complete_auth(id)

func auth_failed(_id: int) -> void:
	if joining: call_deferred("failed")

func host_game() -> void:
	if online or joining: return
	room_secret = "RootsOfTime:1:" + hud.pin.text
	var peer := ENetMultiplayerPeer.new()
	if peer.create_server(PORT,5) != OK:
		hud.net_status("Não foi possível abrir a porta UDP %d." % PORT,false)
		return
	multiplayer.multiplayer_peer = peer
	online = true
	hud.net_status("Hospedando · UDP %d" % PORT,true)

func join_game(address: String) -> void:
	if online or joining or address.is_empty(): return
	room_secret = "RootsOfTime:1:" + hud.pin.text
	var peer := ENetMultiplayerPeer.new()
	if peer.create_client(address,PORT) != OK:
		hud.net_status("Endereço indisponível.",false)
		return
	if not test_mode and not Save.write(farm):
		hud.net_status("Falha ao guardar sua vila.",false)
		return
	multiplayer.multiplayer_peer = peer
	joining = true
	hud.net_status("Conectando…",true)

func joined() -> void:
	joining = false
	connected = true
	online = true
	choose_farmer.rpc_id(1,hud.farmer.button_pressed)
	hud.net_status("Conectado à vila compartilhada",true)

func leave_game() -> void:
	var restore := connected or joining
	if online and not restore:
		for id: int in actors.keys():
			if id != 1: farm.release(id)
	if multiplayer.multiplayer_peer: multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	for id: int in actors.keys(): remove_actor(id)
	online = false
	chat_history.clear()
	chat_times.clear()
	joining = false
	connected = false
	if restore:
		farm = Farm.new()
		if not test_mode: farm.state = Save.recover(farm.state)
	spawn(1)
	routes.clear()
	land.refresh(farm)
	hud.net_status("Individual · você está na sua vila.",false)

func failed() -> void:
	leave_game()
	hud.net_status("Conexão encerrada. Você pode entrar novamente.",false)

func peer_in(id: int) -> void:
	if multiplayer.is_server():
		spawn(id)
		dirty = true
		farm.participants = actors.size()

func peer_out(id: int) -> void:
	if multiplayer.is_server():
		farm.release(id)
		remove_actor(id)
		dirty = true
		farm.participants = actors.size()

func _input(event: InputEvent) -> void:
	if not is_node_ready() or hud.cover.visible: return
	if event is InputEventKey and event.pressed and not event.echo:
		if rebinding:
			rebinding = false
			if event.keycode not in [KEY_ESCAPE,KEY_SHIFT,KEY_W,KEY_A,KEY_S,KEY_D,KEY_UP,KEY_DOWN,KEY_LEFT,KEY_RIGHT]:
				interact_key = event.keycode
				apply_settings()
			hud.info.text = "Interação: " + OS.get_keycode_string(interact_key)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			hud.toggle()
			get_viewport().set_input_as_handled()
		elif not hud.page.visible and event.keycode in [interact_key,KEY_F]:
			use_target()
	if event is InputEventMouseButton and event.pressed and not hud.page.visible:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			var z := camera.zoom.x + (0.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -0.1)
			camera.zoom = Vector2.ONE*clampf(z,0.86,1.75)

func _unhandled_input(event: InputEvent) -> void:
	if hud.cover.visible: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not hud.page.visible:
		var selected := land.nearest(get_global_mouse_position())
		if selected != "" and selected == target: use_target()

func use_target() -> void:
	if joining or target.is_empty(): return
	if connected: request_action.rpc_id(1,target,farm.prompt(multiplayer.get_unique_id(),target))
	else: perform(1,target)

@rpc("any_peer","call_remote","reliable")
func request_action(key: String, expected_action: String) -> void:
	if not multiplayer.is_server() or not land.anchors.has(key): return
	var id := multiplayer.get_remote_sender_id()
	if farm.prompt(id,key) == expected_action: perform(id,key)

func perform(id: int, key: String) -> bool:
	if not actors.has(id) or not land.anchors.has(key): return false
	if actors[id].position.distance_to(land.anchors[key]) > 68: return false
	if Time.get_ticks_msec() - int(last_actions.get(id,-1000)) < 220: return false
	last_actions[id] = Time.get_ticks_msec()
	if (key == "school" and farm.state.family == "out") or (key == "home" and farm.state.family == "back"):
		if kids.any(func(k: Actor) -> bool: return k.position.distance_to(land.anchors[key]) > 105):
			if id == 1: hud.status("Espere as crianças alcançarem a entrada.")
			return false
	var text := farm.act(id,key)
	if text.is_empty(): return false
	dirty = true
	var kind := "grain" if key.begins_with("plot") else "wood"
	if text.begins_with("Canteiro regado"): kind = "water"
	if key in ["table","market","stove"]: kind = "meal"
	if key == "market": kind = "coin"
	if key in ["mill","grater","sieve"]: kind = "mill"
	feedback(id,key,text,kind)
	if online: feedback.rpc(id,key,text,kind)
	land.refresh(farm)
	return true

@rpc("authority","call_remote","reliable")
func feedback(id: int, key: String, message: String, kind: String) -> void:
	if multiplayer.get_unique_id() == id: hud.status(message)
	if actors.has(id):
		var worker: Actor = actors[id]
		worker.activity = "pour" if kind == "water" else ("hoe" if message == "Terra preparada." else "pick")
		worker.action_time = 0.68
	var spot: Vector2 = land.anchors[key]
	sound.play(self,spot,kind,-9)
	if land.visuals.has(key):
		var prop: Node2D = land.visuals[key]
		var bounce := prop.create_tween()
		bounce.tween_property(prop,"scale",Vector2(1.035,0.965),0.09)
		bounce.tween_property(prop,"scale",Vector2.ONE,0.2)

	var dust := CPUParticles2D.new()
	dust.position = spot-Vector2(0,16)
	dust.one_shot = true
	dust.amount = 10
	dust.lifetime = 0.55
	dust.explosiveness = 0.92
	dust.direction = Vector2.UP
	dust.spread = 65
	dust.gravity = Vector2(0,155)
	dust.initial_velocity_min = 34
	dust.initial_velocity_max = 65
	dust.scale_amount_min = 1.5
	dust.scale_amount_max = 3.0
	dust.color = Color("#97cfdf") if kind == "water" else Color("#e7c276")
	add_child(dust)
	dust.finished.connect(dust.queue_free)
	dust.emitting = true

@rpc("any_peer","call_remote","unreliable_ordered")
func input_intent(dir: Vector2) -> void:
	var id := multiplayer.get_remote_sender_id()
	if multiplayer.is_server() and directions.has(id) and dir.is_finite():
		directions[id] = dir.limit_length(1.55)

@rpc("authority","call_remote","reliable")
func receive_world(s: Dictionary, hands: Dictionary) -> void:
	if not connected: return
	farm.state = s
	farm.hands = hands
	land.refresh(farm)

@rpc("authority","call_remote","unreliable_ordered")
func receive(positions: Dictionary, styles: Dictionary, child_pos: PackedVector2Array, clock: float) -> void:
	if not connected: return
	farm.state.time = clock
	for id: int in positions:
		if not actors.has(id):
			spawn(id)
			actors[id].position = positions[id]
	for id: int in actors.keys():
		if not positions.has(id): remove_actor(id)
	for peer: int in styles:
		if actors.has(peer): actors[peer].female = styles[peer]
	destinations = positions
	child_targets = child_pos

@rpc("any_peer","call_remote","reliable")
func choose_farmer(female: bool) -> void:
	var id := multiplayer.get_remote_sender_id()
	if multiplayer.is_server() and actors.has(id): actors[id].female = female

func chat_submit(message: String) -> void:
	if connected: send_chat.rpc_id(1,message)
	elif online: post_chat(1,message)

@rpc("any_peer","call_remote","reliable")
func send_chat(message: String) -> void:
	if multiplayer.is_server(): post_chat(multiplayer.get_remote_sender_id(),message)

func post_chat(id: int, message: String) -> void:
	var clean := message.strip_edges().replace("\n"," ").left(120)
	if clean.is_empty() or not actors.has(id): return
	var now := Time.get_ticks_msec()
	if now-int(chat_times.get(id,-1000)) < 650: return
	chat_times[id] = now
	var line := "%s · %s" % ["Anfitrião" if id == 1 else "Vizinho %04d" % (id%10000),clean]
	show_chat(line)
	show_chat.rpc(line)

@rpc("authority","call_remote","reliable")
func show_chat(line: String) -> void:
	chat_history.append(line)
	if chat_history.size() > 3: chat_history.remove_at(0)
	hud.chat_lines.text = "\n".join(chat_history)
	if not hud.page.visible: hud.status(line)

func local_direction() -> Vector2:
	if hud.cover.visible or hud.page.visible or not get_window().has_focus() and not test_mode: return Vector2.ZERO
	var left := Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)
	var right := Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)
	var up := Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var down := Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
	return Vector2(int(right)-int(left), int(down)-int(up)).normalized() * (1.55 if Input.is_key_pressed(KEY_SHIFT) else 1.0)

func _physics_process(dt: float) -> void:
	if joining: return
	var id := multiplayer.get_unique_id()
	net_timer += dt
	var transmit := net_timer >= 0.085
	if transmit: net_timer = 0.0
	var dir := local_direction()
	if connected:
		if transmit: input_intent.rpc_id(1,dir)
		for peer: int in destinations:
			var avatar: Actor = actors[peer]
			var old := avatar.position
			avatar.position = avatar.position.lerp(destinations[peer],1-exp(-19*dt))
			avatar.pose((avatar.position-old)/dt,dt,farm.hands.get(peer,""))
		for i in range(mini(kids.size(),child_targets.size())):
			var kid := kids[i]
			var old := kid.position
			kid.position = kid.position.lerp(child_targets[i],1-exp(-18*dt))
			kid.pose((kid.position-old)/dt,dt,"")
	else:
		directions[1] = dir
		for peer: int in actors:
			var avatar: Actor = actors[peer]
			avatar.velocity = directions.get(peer,Vector2.ZERO)*155
			avatar.move_and_slide()
			avatar.position = avatar.position.clamp(Layout.BOUNDS.position,Layout.BOUNDS.end)
			avatar.pose(avatar.get_real_velocity(),dt,farm.hands.get(peer,""))
		farm.tick(dt)
		state_timer += dt
		update_escort(dt)
		save_timer += dt
		if save_timer >= 12:
			save_timer = 0
			if not test_mode and not Save.write(farm): hud.status("Falha ao salvar a vila.")
		if transmit:
			land.refresh(farm)
			if online and multiplayer.get_peers().size() > 0:
				var positions := {}
				var styles := {}
				for peer: int in actors:
					positions[peer] = actors[peer].position
					styles[peer] = actors[peer].female
				var spots := PackedVector2Array()
				for kid in kids: spots.append(kid.position)
				receive.rpc(positions,styles,spots,farm.state.time)
				if dirty or state_timer > 0.75:
					receive_world.rpc(farm.state,farm.hands)
					dirty = false
					state_timer = 0.0
	if not actors.has(id): return
	var viewer: Vector2 = actors[id].position
	if last_foot.distance_to(viewer)<12: foot_distance += last_foot.distance_to(viewer)
	last_foot = viewer
	if foot_distance > 43:
		foot_distance = 0
		sound.play(self,viewer,"step",-14)
	camera.position = viewer + Vector2(40,-95)
	weather.position = camera.position-Vector2(0,200)
	weather.emitting = weather.raining(farm.state.time)
	for kid in kids:
		kid.eating = farm.state.family == "eating"
	land.reveal_rooms(viewer,dt)
	for kid in kids: kid.visible = farm.state.family != "school"
	target = land.nearest(viewer)
	highlight.visible = target != "" and not hud.page.visible
	if highlight.visible: highlight.position = land.anchors[target]
	hud.refresh(farm,id,target,OS.get_keycode_string(interact_key))
	bench.visible = farm.state.upgrade
	for key: String in indicators:
		var s: Sprite2D = indicators[key]
		s.visible = farm.state.family == "eating" if key == "table" else farm.state.jobs.has(key)
		if s.visible and key != "table":
			var job: Dictionary = farm.state.jobs[key]
			art.paint(s,Farm.ICON.get(job.product,"meal"),22)
			s.position.y = -34.0 + (sin(farm.state.time*7)*1.7 if farm.state.time < job.ready else 0.0)
	var hour := fmod(390+farm.state.time*2,1440)/1440
	var night := clampf((cos(hour*TAU)-0.05)*1.5,0,1)
	tint.color = Color.WHITE.lerp(Color("#7784a4"),night)
	birds -= dt
	if birds < 0:
		birds = randf_range(7,14)
		sound.play(self,camera.position+Vector2(randf_range(-300,300),-125),"bird",-24)

func update_escort(dt: float) -> void:
	var phase: String = farm.state.family
	if phase == "eating" and farm.state.time >= farm.state.bell:
		farm.state.family = "home"
		phase = "home"
	var changed := phase != family_prev
	family_prev = phase
	for i in range(kids.size()):
		var kid := kids[i]
		var offset := Vector2((i%2)*29-15,(i/2)*22+9)
		var goal := Layout.CHILD_HOME + offset
		if phase == "school":
			kid.position = Layout.CHILD_SCHOOL+offset
			continue
		if phase == "home":
			var turn := float(farm.state.time)/6.5 + i*0.42
			goal = play_points[(int(turn)+i)%play_points.size()]
		elif phase in ["out","back"] and actors.has(farm.state.escort):
			goal = actors[farm.state.escort].position+offset
		elif phase == "eating":
			kid.position = goal
		if changed or farm.state.time >= deadlines.get(i,0.0):
			routes[i] = paths.route(kid.position,goal)
			deadlines[i] = farm.state.time+0.5
		var path: PackedVector2Array = routes.get(i,PackedVector2Array())
		while not path.is_empty() and kid.position.distance_to(path[0]) < 5: path.remove_at(0)
		routes[i] = path
		var prev := kid.position
		if phase != "eating" and not path.is_empty() and kid.position.distance_to(goal)>12:
			var speed := 122.0 if phase == "home" else 250.0
			kid.velocity = kid.position.direction_to(path[0])*minf(speed,kid.position.distance_to(path[0])/dt)
			kid.move_and_slide()
		kid.pose((kid.position-prev)/dt,dt,"")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and is_node_ready() and not connected and not joining and not test_mode:
		Save.write(farm)
