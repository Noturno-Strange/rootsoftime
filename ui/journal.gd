extends CanvasLayer

signal host_requested
signal join_requested(address: String)
signal leave_requested
signal settings_changed
signal chat_requested(message: String)
signal remap_requested
var date_label: Label
var objective: Label
var carry: Label
var hint: Label
var news: Label
var note: Label
var info: Label
var book: Label
var address: LineEdit
var pin: LineEdit
var order_label: Label
var page: PanelContainer
var host_button: Button
var join_button: Button
var leave_button: Button
var farmer: CheckButton
var chat_box := VBoxContainer.new()
var chat_lines: Label
var chat_entry: LineEdit
var levels: Dictionary = {}
var quiet: CheckButton
var steady: CheckButton
var message_until := 0
var serif := SystemFont.new()
var base := Control.new()
const INK := Color("#302c25")
const CREAM := Color("#f3e5cc")

func box(bg: Color, border: Color, margin: int = 12) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(8)
	s.content_margin_left = margin
	s.content_margin_right = margin
	s.content_margin_top = margin*0.65
	s.content_margin_bottom = margin*0.65
	s.shadow_color = Color(0.10,0.09,0.05,0.22)
	s.shadow_size = 4
	return s

func label(parent: Control, value: String, size: int, ink: Color = INK, title: bool = false) -> Label:
	var l := Label.new()
	l.text = value
	l.add_theme_color_override("font_color",ink)
	l.add_theme_font_size_override("font_size",size)
	if title: l.add_theme_font_override("font",serif)
	parent.add_child(l)
	return l

func button(parent: Control, value: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = value
	b.pressed.connect(callback)
	parent.add_child(b)
	return b

func panel(parent: Control, dark: bool = false) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel",box(Color("#344433") if dark else CREAM,Color("#9f865e")))
	parent.add_child(p)
	return p

func _ready() -> void:
	serif.font_names = PackedStringArray(["Georgia","Liberation Serif","DejaVu Serif"])
	var theme := Theme.new()
	theme.default_font_size = 16
	for state: String in ["normal","hover","pressed","focus"]:
		theme.set_stylebox(state,"Button",box(Color("#465d45") if state=="normal" else Color("#687a51"),Color("#b39a69"),10))
	base.theme = theme
	add_child(base)
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var almanac := panel(base)
	almanac.position = Vector2(24,20)
	var column := VBoxContainer.new()
	almanac.add_child(column)
	label(column,"ROOTS OF TIME",12,Color("#68754c"))
	date_label = label(column,"",24,INK,true)
	objective = label(column,"",14)
	order_label = label(column,"",13,Color("#657447"))
	var tools := HBoxContainer.new()
	base.add_child(tools)
	tools.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	tools.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	tools.offset_right = -24
	tools.offset_top = 20
	button(tools,"Caderno   Esc",toggle)
	var pouch := panel(base,true)
	pouch.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	pouch.grow_vertical = Control.GROW_DIRECTION_BEGIN
	pouch.offset_left = 24
	pouch.offset_bottom = -20
	carry = label(pouch,"",17,CREAM)
	var context := VBoxContainer.new()
	base.add_child(context)
	context.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	context.grow_horizontal = Control.GROW_DIRECTION_BOTH
	context.grow_vertical = Control.GROW_DIRECTION_BEGIN
	context.offset_bottom = -22
	news = label(context,"",17,Color.WHITE)
	hint = label(context,"",18,Color.WHITE)
	for l in [news,hint]:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.add_theme_color_override("font_outline_color",Color("#403b2a"))
		l.add_theme_constant_override("outline_size",5)
	page = panel(base)
	page.custom_minimum_size.x = 520
	page.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	page.grow_horizontal = Control.GROW_DIRECTION_BOTH
	page.grow_vertical = Control.GROW_DIRECTION_BOTH
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation",8)
	page.add_child(layout)
	label(layout,"Caderno da vila",32,INK,true)
	var tabs := TabContainer.new()
	tabs.custom_minimum_size = Vector2(540,300)
	layout.add_child(tabs)
	var village_tab := VBoxContainer.new()
	village_tab.name = "Vila"
	tabs.add_child(village_tab)
	var cookbook := VBoxContainer.new()
	cookbook.name = "Receitas"
	tabs.add_child(cookbook)
	var session := VBoxContainer.new()
	session.name = "Cooperativo"
	tabs.add_child(session)
	var options := VBoxContainer.new()
	options.name = "Opções"
	tabs.add_child(options)
	for tab in [village_tab,cookbook,session,options]: tab.add_theme_constant_override("separation",8)
	tabs.add_theme_stylebox_override("panel",box(Color("#f6ecd9"),Color("#c0ac88")))
	label(village_tab,"Do canteiro à mesa",23,INK,true)
	note = label(village_tab,"",16)
	book = label(village_tab,"",15)
	book.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label(cookbook,"Tradições da cozinha",23,INK,true)
	label(cookbook,"Milho → moinho → fubá → fogão → angu\nMilho → ralador → massa de milho → forno → pamonha\nMandioca → lavar → ralar → prensar → peneirar → torrar\nMassa peneirada → chapa → beiju\nFubá + ovos → bancada → massa de broa → forno\nArroz branco + feijão de panela → bancada → fogão\nLeite + manga → bancada → fogão\nOvos ou leite → chapa   ·   Manga → fogão",16)
	label(options,"Conforto e personagem",23,INK,true)
	label(session,"Partida cooperativa",23,INK,true)
	var row := HBoxContainer.new()
	session.add_child(row)
	address = LineEdit.new()
	address.placeholder_text = "Endereço do anfitrião"
	address.custom_minimum_size.x = 195
	row.add_child(address)
	host_button = button(row,"Hospedar",func() -> void: host_requested.emit())
	join_button = button(row,"Entrar",func() -> void: join_requested.emit(address.text.strip_edges()))
	leave_button = button(row,"Sair da sala",func() -> void: leave_requested.emit())
	pin = LineEdit.new()
	pin.placeholder_text = "Senha opcional da sala"
	pin.secret = true
	pin.max_length = 48
	session.add_child(pin)
	info = label(session,"",14)
	steady = CheckButton.new()
	steady.text = "Câmera sem suavização"
	quiet = CheckButton.new()
	quiet.text = "Silenciar o jogo"
	farmer = CheckButton.new()
	farmer.text = "Jogar como agricultora"
	session.add_child(chat_box)
	chat_lines = label(chat_box,"",14)
	chat_lines.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chat_entry = LineEdit.new()
	chat_entry.placeholder_text = "Converse com a vila · Enter para enviar"
	chat_entry.max_length = 120
	chat_box.add_child(chat_entry)
	chat_entry.text_submitted.connect(func(message: String) -> void:
		chat_requested.emit(message)
		chat_entry.clear())
	for check in [steady,quiet,farmer]:
		check.add_theme_color_override("font_color",CREAM)
		options.add_child(check)
		check.toggled.connect(func(_on: bool) -> void: settings_changed.emit())
	var volumes := HBoxContainer.new()
	options.add_child(volumes)
	for bus: String in ["Música","Ambiente","Efeitos"]:
		label(volumes,bus,13)
		var volume := HSlider.new()
		volume.custom_minimum_size.x = 55
		volume.max_value = 1.0
		volume.step = 0.05
		volume.value = 0.8
		volumes.add_child(volume)
		levels[bus] = volume
		volume.value_changed.connect(func(_v: float) -> void: settings_changed.emit())
	var actions := HBoxContainer.new()
	layout.add_child(actions)
	button(options,"Alterar tecla de interação",func() -> void: remap_requested.emit())
	button(actions,"Voltar à vila",toggle)
	page.hide()

func toggle() -> void:
	page.visible = not page.visible
	if not page.visible: base.get_viewport().gui_release_focus()

func status(message: String) -> void:
	news.text = message
	message_until = Time.get_ticks_msec()+3200

func refresh(farm: RefCounted, me: int, target: String, key: String) -> void:
	var s: Dictionary = farm.state
	var minutes := int(390+s.time*2.0)
	date_label.text = "Dia %02d   ·   %02d:%02d" % [1+minutes/1440,(minutes/60)%24,minutes%60]
	objective.text = "%s   ·   %d moedas" % ["Chuva de verão" if preload("res://systems/weather.gd").raining(s.time) else "Sol de verão",s.coins]
	order_label.text = "Feira · %s (%d/%d)" % [farm.ORDERS[int(s.order)],s.delivered,s.quota]
	var item: String = farm.hands.get(me,"")
	carry.text = "Cesto  ·  " + (item if item != "" else "vazio")
	hint.text = "["+key+"]  "+farm.prompt(me,target) if target != "" else ""
	if Time.get_ticks_msec() > message_until: news.text = ""
	note.text = "WASD ou setas para andar · Shift para correr · Roda para zoom\nPrepare, plante e regue um canteiro. Leve o milho ao moinho,\nretire o fubá e cozinhe o angu no fogão junto à casa.\nSirva Lia na mesa ou entregue o prato na feira."
	book.text = "Receitas descobertas: %s\nRefeições servidas: %d   ·   Entregas: %d   ·   Idas à escola: %d" % [", ".join(s.book) if not s.book.is_empty() else "—",s.served,s.sales,s.trips]

func net_status(message: String, in_session: bool) -> void:
	pin.visible = not in_session
	chat_box.visible = in_session
	if not in_session: chat_lines.text = ""
	info.text = message
	host_button.visible = not in_session
	join_button.visible = not in_session
	address.visible = not in_session
	leave_button.visible = in_session
