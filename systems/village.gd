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
var play_points := [Vector2(520,585),Vector2(830,545),Vector2(1150,445),Vector2(940,580),Vector2(740,820)]
var tint := CanvasModulate.new()
var paths := preload("res://systems/paths.gd").new()
var target := ""
var goal_pin := Label.new()
var highlight := Line2D.new()
var interact_key := KEY_E
var rebinding := false
var room_secret := ""
var state_timer := 0.0
# Posição do alimento no tampo ou na abertura, em fração da altura da arte.
const DISPLAY_HEIGHT := {"table":0.60, "stove":0.62, "mill":0.17, "press":0.39,
	"wash":0.69, "grater":0.43, "sieve":0.59, "pan":0.60, "oven":0.40}

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
var tray_items: Array[Sprite2D] = []
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
	for i in range(Farm.TRAY_CAPACITY):
		var portion: Sprite2D = art.sprite("ear",16)
		portion.position = preload("res://systems/serving_tray.gd").PLACES[i]
		land.visuals.tray.add_child(portion)
		tray_items.append(portion)
	add_child(tint)
	bench = land.place("bench",Vector2(930,542),43)
	var stations: Array = farm.recipes.keys()
	stations.append("table")
	for k: String in stations:
		var s: Sprite2D = art.sprite("meal",24)
		s.position = Vector2(12, -float(Layout.SITES[k][2]) * DISPLAY_HEIGHT[k])
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
	camera.limit_right = int(Layout.WORLD_SIZE.x)
	camera.limit_bottom = int(Layout.WORLD_SIZE.y)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8
	camera.zoom = Vector2.ONE * 1.32
	camera.offset = Vector2.ZERO
	var ear := AudioListener2D.new()
	camera.add_child(ear)
	ear.make_current()
	hud.base.add_child(goal_pin)
	goal_pin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	goal_pin.add_theme_font_size_override("font_size",28)
	goal_pin.add_theme_color_override("font_color",Color("#ffda67"))
	goal_pin.add_theme_color_override("font_outline_color",Color("#482717"))
	goal_pin.add_theme_constant_override("outline_size",6)
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
		hud.key_button.text = "Pressione uma tecla · Esc para cancelar")
	hud.settings_changed.connect(apply_settings)
	settings.load("user://opcoes.cfg")
	interact_key = int(settings.get_value("input","interact",KEY_E))
	hud.quiet.set_pressed_no_signal(settings.get_value("audio","mute",false))
	hud.steady.set_pressed_no_signal(settings.get_value("camera","steady",false))
	for bus: String in hud.levels:
		hud.levels[bus].set_value_no_signal(settings.get_value("mix",bus,0.8))
	hud.show_avatar(int(settings.get_value("avatar","index",int(settings.get_value("avatar","female",false)))))
	hud.fullscreen.set_pressed_no_signal(settings.get_value("display","fullscreen",false))
	hud.resolution.select(clampi(int(settings.get_value("display","resolution",1)),0,hud.SIZES.size()-1))
	hud.display_changed.connect(apply_display)
	apply_display()
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

func apply_display() -> void:
	var full: bool = hud.fullscreen.button_pressed
	hud.resolution.disabled = full
	if DisplayServer.get_name() != "headless":
		var window := get_window()
		window.mode = Window.MODE_FULLSCREEN if full else Window.MODE_WINDOWED
		if not full:
			var area := DisplayServer.screen_get_usable_rect(window.current_screen)
			var size_wanted: Vector2i = hud.SIZES[hud.resolution.selected]
			var room := Vector2(area.size - Vector2i(20,52))
			var scale_factor := minf(1.0,minf(room.x/size_wanted.x,room.y/size_wanted.y))
			window.size = Vector2i(Vector2(size_wanted)*scale_factor)
			window.position = area.position + (area.size-window.size)/2
	settings.set_value("display","fullscreen",full)
	settings.set_value("display","resolution",hud.resolution.selected)
	if not test_mode: settings.save("user://opcoes.cfg")

func apply_settings() -> void:
	camera.position_smoothing_enabled = not hud.steady.button_pressed
	AudioServer.set_bus_mute(0,hud.quiet.button_pressed)
	for bus: String in hud.levels:
		var level: float = hud.levels[bus].value
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus),linear_to_db(maxf(level,0.0001)))
		settings.set_value("mix",bus,level)
	settings.set_value("avatar","index",hud.avatar)
	hud.key_button.text = "Tecla de interação · " + OS.get_keycode_string(interact_key)
	if connected: choose_farmer.rpc_id(1,hud.avatar)
	elif actors.has(1): actors[1].appearance = hud.avatar
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
	actor.appearance = hud.avatar if id == 1 and not connected else 0
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
	choose_farmer.rpc_id(1,hud.avatar)
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
		if hud.kit.visible:
			if event.keycode in [KEY_ESCAPE,KEY_B]: hud.close_tools()
			elif event.keycode >= KEY_1 and event.keycode <= KEY_4: hud.equip_tool(event.keycode-KEY_1)
			else: return
			get_viewport().set_input_as_handled()
			return
		if rebinding:
			rebinding = false
			if event.keycode not in [KEY_B,KEY_ESCAPE,KEY_SHIFT,KEY_W,KEY_A,KEY_S,KEY_D,KEY_UP,KEY_DOWN,KEY_LEFT,KEY_RIGHT]:
				interact_key = event.keycode
				apply_settings()
			hud.key_button.text = "Tecla de interação · " + OS.get_keycode_string(interact_key)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_B and not hud.page.visible:
			hud.open_tools()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			hud.toggle()
			get_viewport().set_input_as_handled()
		elif not hud.page.visible and event.keycode in [interact_key,KEY_F]:
			use_target()
	if event is InputEventMouseButton and event.pressed and not hud.page.visible and not hud.kit.visible:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			var step := 1 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1
			if event.ctrl_pressed:
				var z := clampf(camera.zoom.x-step*0.1,0.86,1.75)
				camera.zoom = Vector2.ONE*z
			else:
				hud.equip_tool(posmod(hud.tool_id+step,hud.TOOL_NAMES.size()))
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if hud.cover.visible: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not hud.page.visible and not hud.kit.visible:
		var selected := land.nearest(get_global_mouse_position())
		if selected != "" and selected == target: use_target()

func use_target() -> void:
	if joining or target.is_empty(): return
	if connected: request_action.rpc_id(1,target,farm.prompt(multiplayer.get_unique_id(),target,hud.tool_id),hud.tool_id)
	else: perform(1,target,hud.tool_id)

@rpc("any_peer","call_remote","reliable")
func request_action(key: String, expected_action: String, tool: int) -> void:
	if not multiplayer.is_server() or not land.anchors.has(key): return
	var id := multiplayer.get_remote_sender_id()
	if tool < 0 or tool >= Farm.TOOL_NAMES.size(): return
	if farm.prompt(id,key,tool) == expected_action: perform(id,key,tool)

func perform(id: int, key: String, tool: int = 0) -> bool:
	if not actors.has(id) or not land.anchors.has(key): return false
	if key == "teacher" and not land.inside_building("school",actors[id].position): return false
	var needed := farm.required_tool(key)
	if needed >= 0 and tool != needed: return false
	var reach := 32 if Farm.FRUIT_SPOTS.has(key) else 68
	if actors[id].position.distance_to(land.anchors[key]) > reach: return false
	var recovery := 850 if farm.sore(id) and key.begins_with("plot") else 220
	if Time.get_ticks_msec() - int(last_actions.get(id,-1000)) < recovery: return false
	last_actions[id] = Time.get_ticks_msec()
	if (key == "school" and farm.state.family == "out") or (key == "home" and farm.state.family == "back"):
		if kids.any(func(k: Actor) -> bool: return k.position.distance_to(land.anchors[key]) > 105):
			if id == 1: hud.status("Espere as crianças alcançarem a entrada.")
			return false
	var text := farm.act(id,key,tool)
	if text.is_empty():
		var reason := farm.prompt(id,key,tool)
		if id == multiplayer.get_unique_id(): report_blocked(reason)
		elif online: report_blocked.rpc_id(id,reason)
		return false
	dirty = true
	var kind := "grain" if key.begins_with("plot") else "wood"
	if key == "well" or text.begins_with("Canteiro regado"): kind = "water"
	if key in ["table","market","stove"]: kind = "meal"
	if key in ["market","warehouse"] or Farm.OFFERS.has(key): kind = "coin"
	if key == "homestead": kind = "unlock"
	if Farm.STOCK_PRICE.has(key): kind = "care"
	if key in ["home","school","teacher","healer"] or Farm.NEIGHBORS.has(key): kind = "voice"
	if Farm.FRUIT_SPOTS.has(key) or text.begins_with("Colheita"): kind = "harvest"
	if key in ["mill","grater","sieve"]: kind = "mill"
	feedback(id,key,text,kind)
	if online: feedback.rpc(id,key,text,kind)
	land.refresh(farm)
	return true

@rpc("authority","call_remote","reliable")
func report_blocked(reason: String) -> void:
	hud.status(reason)
	if actors.has(multiplayer.get_unique_id()):
		sound.play(self,actors[multiplayer.get_unique_id()].position,"wood",-22)

@rpc("authority","call_remote","reliable")
func feedback(id: int, key: String, message: String, kind: String) -> void:
	if multiplayer.get_unique_id() == id: hud.status(message)
	if kind == "voice":
		sound.play(self,land.anchors[key],kind,-16)
		return
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
	dust.color = {"coin":Color("#ffd34f"),"unlock":Color("#ffed94"),"harvest":Color("#a4ce66"),"care":Color("#ffbbaa"),"water":Color("#97cfdf"),"meal":Color("#fff0cb")}.get(kind,Color("#e7c276"))
	if kind in ["unlock","coin","care","harvest"]:
		dust.gravity = Vector2(0,-28)
		dust.amount = 18 if kind == "unlock" else 9
		dust.lifetime = 0.8
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
		if actors.has(peer): actors[peer].appearance = styles[peer]
	destinations = positions
	child_targets = child_pos

@rpc("any_peer","call_remote","reliable")
func choose_farmer(index: int) -> void:
	var id := multiplayer.get_remote_sender_id()
	if multiplayer.is_server() and actors.has(id) and index >= 0 and index < hud.NAMES.size(): actors[id].appearance = index

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
	if hud.cover.visible or hud.kit.visible or hud.page.visible or not get_window().has_focus() and not test_mode: return Vector2.ZERO
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
			avatar.velocity = directions.get(peer,Vector2.ZERO)*(120 if farm.unwell(peer) and not farm.sore(peer) else 155)
			avatar.move_and_slide()
			avatar.position = avatar.position.clamp(Layout.BOUNDS.position,Layout.BOUNDS.end)
			avatar.pose(avatar.get_real_velocity(),dt,farm.hands.get(peer,""))
		if online or not (hud.cover.visible or hud.page.visible or hud.kit.visible):
			farm.tick(dt)
			update_escort(dt)
		state_timer += dt
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
					styles[peer] = actors[peer].appearance
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
	camera.position = viewer + Vector2(40,-155)
	weather.position = camera.position-Vector2(0,200)
	weather.emitting = weather.raining(farm.state.time)
	land.update_fruits(farm)
	land.update_fair(farm,dt,viewer,sound)
	for kid in kids:
		kid.eating = farm.state.family == "eating"
	land.reveal_rooms(viewer,dt)
	for kid in kids: kid.visible = farm.state.family != "school"
	target = land.nearest(viewer)
	highlight.visible = target != "" and not hud.page.visible
	if highlight.visible: highlight.position = land.anchors[target]
	update_goal(id)
	hud.refresh(farm,id,target,OS.get_keycode_string(interact_key))
	bench.visible = farm.state.upgrade
	for i in range(tray_items.size()):
		var portion := tray_items[i]
		portion.visible = i < farm.state.tray.size()
		if portion.visible: art.paint(portion,Farm.ICON[farm.state.tray[i]],16)
	for key: String in indicators:
		var s: Sprite2D = indicators[key]
		s.visible = farm.state.family == "eating" if key == "table" else farm.state.jobs.has(key)
		if s.visible and key == "table" and farm.state.served_item != "":
			art.paint(s,Farm.ICON[farm.state.served_item],20)
		if s.visible and key != "table":
			var job: Dictionary = farm.state.jobs[key]
			art.paint(s,Farm.ICON.get(job.product,"meal"),22)
			s.position.y = -float(Layout.SITES[key][2]) * DISPLAY_HEIGHT[key] + (sin(farm.state.time*7)*1.7 if farm.state.time < job.ready else 0.0)
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

func update_goal(id: int) -> void:
	var goal := "market"
	var order: String = Farm.ORDERS[int(farm.state.order)]
	var caption := "Feira · pedido de " + order
	if farm.hands.get(id,"") == order: caption = "Entregar " + order
	elif farm.state.jobs.size() > 0:
		for station: String in farm.state.jobs:
			var job: Dictionary = farm.state.jobs[station]
			if farm.state.time >= job.ready and farm.hands.get(id,"") == "":
				goal = station
				caption = "Retirar " + str(job.product)
				break
	if farm.state.water == 0 and hud.tool_id == 2:
		goal = "well"
		caption = "Abasteça o regador no poço"
	if farm.state.escort == id:
		goal = "home" if farm.state.family == "back" else "school"
		caption = "Voltar para casa" if goal == "home" else "Levar à escola"
	elif farm.state.family == "school" and farm.state.time >= farm.state.bell:
		goal = "school"
		caption = "Buscar na escola"
	if farm.unwell(id):
		goal = "healer"
		caption = ("Dor muscular" if farm.sore(id) else "Mal-estar") + " · procure o pajé a leste"
	var point: Vector2 = get_canvas_transform()*(land.anchors[goal]-Vector2(0,38))
	var safe := point.clamp(Vector2(20,92),get_viewport_rect().size-Vector2(48,90))
	var direction := point-safe
	goal_pin.text = "◆" if direction.length()<1 else ["→","↘","↓","↙","←","↖","↑","↗"][posmod(roundi(direction.angle()/(PI/4)),8)]
	goal_pin.position = safe+Vector2(0,3*sin(farm.state.time*3))
	goal_pin.visible = not hud.page.visible
	hud.destination.text = "◆  "+caption
