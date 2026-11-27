extends CanvasLayer

signal host_requested
signal join_requested(address: String)
signal leave_requested
signal settings_changed
signal chat_requested(message: String)
signal remap_requested
const Farm = preload("res://systems/farm.gd")
const TOOL_NAMES := ["Enxada","Sementes","Regador","Cesto"]
const TOOL_ICONS := ["hoe","seedling","can","basket"]
var tool_flash: Tween
var tool_id := 0
var kit := ColorRect.new()
var slots: Array[Button] = []
var task_meter := ProgressBar.new()
var task_detail: Label
var kit_button: Button
var catalog: Array[String] = []
var methods := {}
var current_recipe := 0
var page_text: Label
var back_page: Button
var next_page: Button
var dishes: Array[Button] = []
var destination: Label
var art := preload("res://systems/art.gd").new()
var carry_icon := TextureRect.new()
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
var cover := Control.new()
var spread_art := TextureRect.new()
var spread_caption: Label
var recipe_note: Label
var tabs := TabContainer.new()
var page: PanelContainer
var host_button: Button
var join_button: Button
var leave_button: Button
const PORTRAITS := ["farmer","woman1","davi0","rosa0"]
const NAMES := ["Bento","Clara","Davi","Rosa"]
const SIZES := [Vector2i(960,540),Vector2i(1280,720),Vector2i(1600,900),Vector2i(1920,1080),Vector2i(2560,1440)]
var avatar := 0
var cards: Array[Button] = []
var sections := TabContainer.new()
var resolution := OptionButton.new()
var fullscreen := CheckButton.new()
var key_button: Button
signal display_changed
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
	s.set_border_width_all(2)
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

func parchment() -> StyleBoxTexture:
	var paper := AtlasTexture.new()
	paper.atlas = preload("res://assets/book.webp")
	paper.region = Rect2(0,0,520,550)
	var frame := StyleBoxTexture.new()
	frame.texture = paper
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		frame.set_texture_margin(side,16)
		frame.set_content_margin(side,18)
	return frame

func panel(parent: Control, dark: bool = false) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel",box(Color("#344433") if dark else CREAM,Color("#9f865e")))
	if not dark: p.add_theme_stylebox_override("panel",parchment())
	parent.add_child(p)
	return p

func _ready() -> void:
	serif.font_names = PackedStringArray(["Georgia","Liberation Serif","DejaVu Serif"])
	var theme := Theme.new()
	theme.default_font_size = 16
	for state: String in ["normal","hover","pressed","focus"]:
		theme.set_stylebox(state,"Button",box(Color("#904327") if state=="normal" else Color("#68402c"),Color("#b39a69"),10))
	for state in ["tab_selected","tab_unselected","tab_hovered"]:
		theme.set_stylebox(state,"TabContainer",box(Color("#43593d") if state=="tab_selected" else Color("#765035"),Color("#b99053"),10))
	for state in ["font_selected_color","font_unselected_color","font_hovered_color"]:
		theme.set_color(state,"TabContainer",Color.WHITE)
	base.theme = theme
	add_child(base)
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var almanac := panel(base)
	almanac.position = Vector2(24,20)
	var column := HBoxContainer.new()
	column.add_theme_constant_override("separation",18)
	almanac.add_child(column)
	label(column,"Roots of Time",23,INK,true)
	date_label = label(column,"",21,INK,true)
	objective = label(column,"",15)
	var requests := panel(base)
	requests.position = Vector2(24,108)
	var orders := VBoxContainer.new()
	requests.add_child(orders)
	label(orders,"Pedidos da vila",20,Color("#87371f"),true)
	order_label = label(orders,"",17,INK)
	destination = label(orders,"",16,Color("#435626"))
	task_detail = label(orders,"",15)
	task_meter.custom_minimum_size = Vector2(200,9)
	task_meter.show_percentage = false
	task_meter.add_theme_stylebox_override("fill",box(Color("#526a37"),Color("#a79348"),0))
	orders.add_child(task_meter)
	var tools := HBoxContainer.new()
	base.add_child(tools)
	tools.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	tools.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	tools.offset_right = -24
	tools.offset_top = 20
	kit_button = button(tools,"Enxada   [B]",open_tools)
	kit_button.icon = art.textures[TOOL_ICONS[0]]
	kit_button.add_theme_constant_override("icon_max_width",32)
	kit_button.tooltip_text = "Roda para trocar · Ctrl + roda para zoom"
	build_kit(theme)
	button(tools,"Caderno   Esc",toggle)
	var pouch := panel(base,true)
	pouch.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	pouch.grow_vertical = Control.GROW_DIRECTION_BEGIN
	pouch.offset_left = 24
	pouch.offset_bottom = -20
	var held_row := HBoxContainer.new()
	pouch.add_child(held_row)
	carry_icon.custom_minimum_size = Vector2(39,35)
	carry_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	carry_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	held_row.add_child(carry_icon)
	carry = label(held_row,"",17,CREAM)
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
	var binding := StyleBoxTexture.new()
	binding.texture = preload("res://assets/book.webp")
	for side in [SIDE_LEFT,SIDE_RIGHT]: binding.set_content_margin(side,45)
	for side in [SIDE_TOP,SIDE_BOTTOM]: binding.set_content_margin(side,44)
	page.add_theme_stylebox_override("panel",binding)
	page.custom_minimum_size = Vector2(1090,510)
	page.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	page.grow_horizontal = Control.GROW_DIRECTION_BOTH
	page.grow_vertical = Control.GROW_DIRECTION_BOTH
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation",8)
	var spread := HBoxContainer.new()
	page.add_child(spread)
	spread.add_theme_constant_override("separation",64)
	spread.add_child(layout)
	layout.custom_minimum_size.x = 458
	var illustration := VBoxContainer.new()
	illustration.alignment = BoxContainer.ALIGNMENT_CENTER
	illustration.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spread.add_child(illustration)
	spread_art.custom_minimum_size = Vector2(230,215)
	spread_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	spread_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	illustration.add_child(spread_art)
	spread_caption = label(illustration,"",24,INK,true)
	spread_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spread_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recipe_note = label(illustration,"",17,INK)
	recipe_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recipe_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	recipe_note.hide()
	tabs.tab_changed.connect(func(i: int) -> void:
		recipe_note.visible = i == 1
		if i == 1: recipe_note.text = "Leve milho ao moinho. Retire o fubá e cozinhe no fogão."
		spread_art.texture = art.textures[["home","angu","market","farmer"][i]]
		spread_caption.text = ["A vila","Angu","Feira comunitária","Personagem"][i]
		if i == 1: show_recipe(current_recipe)
		if i == 3: show_avatar(avatar))
	spread_art.texture = art.textures["home"]
	spread_caption.text = "A vila"
	label(layout,"Caderno da vila",32,INK,true)
	tabs.custom_minimum_size = Vector2(450,300)
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
	tabs.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	label(village_tab,"Do canteiro à mesa",23,INK,true)
	note = label(village_tab,"",16)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	book = label(village_tab,"",15)
	book.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label(cookbook,"Tradições da cozinha",23,INK,true)
	var farm := Farm.new()
	var stations := {"mill":"Moinho","press":"Prensa","stove":"Fogão","wash":"Tanque","grater":"Ralador","sieve":"Peneira","oven":"Forno","pan":"Chapa"}
	catalog.assign(Farm.MEALS)
	for station: String in farm.recipes:
		for ingredient: String in farm.recipes[station]:
			var product: String = farm.recipes[station][ingredient][0]
			methods[product] = [stations[station],[ingredient]]
	for pair: String in Farm.BLENDS:
		methods[Farm.BLENDS[pair]] = ["Bancada",pair.split("|")]
	for product: String in methods:
		if not catalog.has(product): catalog.append(product)
	var plates := GridContainer.new()
	plates.columns = 2
	cookbook.add_child(plates)
	for i in 4:
		var card := button(plates,"",func() -> void: show_recipe((current_recipe/4)*4+i))
		card.custom_minimum_size = Vector2(210,50)
		card.add_theme_constant_override("icon_max_width",40)
		dishes.append(card)
	var pages := HBoxContainer.new()
	cookbook.add_child(pages)
	back_page = button(pages,"‹ Anterior",func() -> void: show_recipe((current_recipe/4-1)*4))
	page_text = label(pages,"",17)
	next_page = button(pages,"Próxima ›",func() -> void: show_recipe((current_recipe/4+1)*4))
	options.add_child(sections)
	sections.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	var cast := section("Personagem")
	var screen := section("Tela")
	var audio := section("Som e controles")
	sections.tab_changed.connect(func(_i: int) -> void: show_avatar(avatar))
	label(cast,"Quem vai cuidar da vila?",22,INK,true)
	var choices := GridContainer.new()
	choices.columns = 2
	cast.add_child(choices)
	var group := ButtonGroup.new()
	for i in NAMES.size():
		var card := button(choices,NAMES[i],func() -> void: show_avatar(i); settings_changed.emit())
		card.toggle_mode = true
		card.button_group = group
		card.custom_minimum_size = Vector2(174,61)
		card.add_theme_stylebox_override("pressed",box(Color("#36563a"),Color("#d79e38"),10))
		card.icon = art.textures[PORTRAITS[i]]
		card.add_theme_constant_override("icon_max_width",40)
		cards.append(card)
	label(screen,"Exibição do jogo",22,INK,true)
	screen.add_child(fullscreen)
	fullscreen.text = "Tela cheia"
	style_check(fullscreen)
	fullscreen.toggled.connect(func(_on: bool) -> void: display_changed.emit())
	label(screen,"Resolução em janela",17)
	screen.add_child(resolution)
	for dimensions: Vector2i in SIZES:
		resolution.add_item("%d × %d" % [dimensions.x,dimensions.y])
	resolution.item_selected.connect(func(_i: int) -> void: display_changed.emit())
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
	for check in [steady,quiet]:
		style_check(check)
		(audio if check == quiet else screen).add_child(check)
		check.toggled.connect(func(_on: bool) -> void: settings_changed.emit())
	var volumes := GridContainer.new()
	volumes.columns = 2
	audio.add_child(volumes)
	for bus: String in ["Música","Ambiente","Efeitos"]:
		label(volumes,bus,16)
		var volume := HSlider.new()
		volume.custom_minimum_size.x = 180
		volume.max_value = 1.0
		volume.step = 0.05
		volume.value = 0.8
		volumes.add_child(volume)
		levels[bus] = volume
		volume.value_changed.connect(func(_v: float) -> void: settings_changed.emit())
	var actions := HBoxContainer.new()
	layout.add_child(actions)
	key_button = button(audio,"Tecla de interação",func() -> void: remap_requested.emit())
	button(actions,"Voltar à vila",toggle)
	button(actions,"Sair do jogo",exit_game)
	page.hide()
	page.visibility_changed.connect(func() -> void:
		for widget in [almanac,requests,tools,pouch,context]: widget.visible = not page.visible)

	add_child(cover)
	cover.theme = theme
	cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var scene := TextureRect.new()
	scene.texture = preload("res://assets/title.webp")
	scene.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cover.add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var enter: Button
	var entries := ["Continuar","Personagem","Cooperativo","Opções","Sair"]
	for i in range(entries.size()):
		var b := Button.new()
		b.tooltip_text = entries[i]
		b.accessibility_name = entries[i]
		scene.add_child(b)
		b.anchor_left = 0.058
		b.anchor_right = 0.277
		b.anchor_top = [0.392,0.476,0.555,0.636,0.717][i]
		b.anchor_bottom = b.anchor_top+0.075
		var blank := StyleBoxFlat.new()
		blank.bg_color = Color.TRANSPARENT
		b.add_theme_stylebox_override("normal",blank)
		var focus := blank.duplicate() as StyleBoxFlat
		focus.bg_color = Color(1,0.87,0.53,0.16)
		focus.set_corner_radius_all(24)
		for state in ["hover","pressed","focus"]: b.add_theme_stylebox_override(state,focus)
		if i == 1:
			b.text = "Personagem"
			b.add_theme_font_override("font",serif)
			b.add_theme_font_size_override("font_size",26)
			b.add_theme_color_override("font_color",INK)
			b.add_theme_color_override("font_hover_color",INK)
			b.add_theme_color_override("font_focus_color",INK)

		if i == 0: enter = b
		b.pressed.connect(func() -> void:
			if i == 4:
				exit_game()
			else:
				sections.current_tab = 1 if i == 3 else 0
				enter_village([-1,3,2,3][i]))
	cover.visible = "--test" not in OS.get_cmdline_user_args()
	base.visible = not cover.visible
	if cover.visible: enter.grab_focus()

func section(title: String) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.name = title
	column.add_theme_constant_override("separation",8)
	sections.add_child(column)
	return column

func style_check(check: CheckButton) -> void:
	for key in ["font_color","font_hover_color","font_pressed_color","font_focus_color","font_hover_pressed_color"]:
		check.add_theme_color_override(key,Color.WHITE)

func show_avatar(index: int) -> void:
	avatar = clampi(index,0,NAMES.size()-1)
	for i in cards.size(): cards[i].set_pressed_no_signal(i == avatar)
	if tabs.current_tab == 3:
		spread_art.texture = art.textures[PORTRAITS[avatar]]
		spread_caption.text = NAMES[avatar]
		if sections.current_tab == 1:
			spread_art.texture = art.textures["home"]
			spread_caption.text = "Exibição da vila"
		elif sections.current_tab == 2:
			spread_art.texture = art.textures["market"]
			spread_caption.text = "Som e controles"

func exit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func enter_village(tab: int) -> void:
	cover.hide()
	base.show()
	if tab >= 0:
		tabs.current_tab = tab
		page.show()

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
	carry_icon.texture = art.textures.get(farm.ICON.get(item,"meal") if item != "" else "basket")
	carry.text = "Cesto  ·  " + (item if item != "" else "vazio")
	hint.text = "["+key+"]  "+farm.prompt(me,target) if target != "" else ""
	var needed: int = farm.required_tool(target)
	if needed >= 0 and needed != tool_id: hint.text = "[B] Equipar %s · %s" % [TOOL_NAMES[needed],farm.prompt(me,target)]
	task_detail.text = ""
	task_meter.max_value = s.quota
	task_meter.value = s.delivered
	if s.jobs.has(target):
		var job: Dictionary = s.jobs[target]
		var left := maxi(0,ceili(float(job.ready)-float(s.time)))
		task_detail.text = "%s · %d s" % [job.product,left] if left > 0 else "%s pronto para retirar" % job.product
	elif target.begins_with("plot"):
		var plot: Dictionary = s.plots[target.trim_prefix("plot").to_int()]
		var stage := int(plot.stage)
		task_detail.text = ["Preparar a terra","Plantar as sementes","Regar","Crescendo","Pronto para colher"][stage]
		if stage == 3: task_detail.text += " · %d s" % maxi(0,ceili(float(plot.ready)-float(s.time)))
	task_detail.visible = task_detail.text != ""
	if Time.get_ticks_msec() > message_until: news.text = ""
	note.text = "WASD ou setas para andar · Shift para correr\nRoda para trocar ferramenta · Ctrl + roda para zoom\nPrepare, plante e regue um canteiro. Leve o milho ao moinho,\nretire o fubá e cozinhe o angu no fogão junto à casa.\nSirva as crianças na mesa ou entregue o prato na feira."
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

func build_kit(theme: Theme) -> void:
	add_child(kit)
	kit.theme = theme
	kit.color = Color(0.10,0.08,0.04,0.64)
	kit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	kit.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var chest := panel(center)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	chest.add_child(column)
	var heading := HBoxContainer.new()
	column.add_child(heading)
	var chest_icon := TextureRect.new()
	chest_icon.texture = art.textures["chest"]
	chest_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chest_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chest_icon.custom_minimum_size = Vector2(62,44)
	heading.add_child(chest_icon)
	label(heading,"Baú de ferramentas",30,INK,true)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",8)
	column.add_child(grid)
	var uses := ["Preparar a terra","Plantar no canteiro","Regar o plantio","Recolher a colheita"]
	for i in TOOL_NAMES.size():
		var slot := button(grid,"",func() -> void: equip_tool(i))
		slot.icon = art.textures[TOOL_ICONS[i]]
		slot.add_theme_constant_override("icon_max_width",44)
		slot.custom_minimum_size = Vector2(240,80)
		slot.tooltip_text = uses[i]
		slots.append(slot)
	button(column,"Voltar à vila   [Esc]",close_tools)
	kit.hide()

func open_tools() -> void:
	base.hide()
	kit.show()
	for i in slots.size():
		slots[i].text = "%d   %s%s" % [i+1,TOOL_NAMES[i],"\nEm uso" if i == tool_id else ""]
		slots[i].add_theme_stylebox_override("normal",box(Color("#3c5634") if i == tool_id else Color("#88482c"),Color("#bc9762"),12))
	slots[tool_id].grab_focus()

func close_tools() -> void:
	kit.hide()
	base.show()
	base.get_viewport().gui_release_focus()

func equip_tool(index: int) -> void:
	tool_id = index
	if kit.visible: close_tools()
	kit_button.icon = art.textures[TOOL_ICONS[index]]
	if tool_flash: tool_flash.kill()
	kit_button.modulate = Color("#ffe19a")
	tool_flash = kit_button.create_tween()
	tool_flash.tween_property(kit_button,"modulate",Color.WHITE,0.38)
	kit_button.text = "%s   [B]" % TOOL_NAMES[index]
	status("%s em uso." % TOOL_NAMES[index])

func show_recipe(index: int) -> void:
	current_recipe = clampi(index,0,catalog.size()-1)
	var leaf := current_recipe/4
	for i in dishes.size():
		var n := leaf*4+i
		dishes[i].visible = n < catalog.size()
		if dishes[i].visible:
			dishes[i].text = catalog[n]
			dishes[i].icon = art.textures[Farm.ICON[catalog[n]]]
			dishes[i].add_theme_stylebox_override("normal",box(Color("#39563a") if n == current_recipe else Color("#874628"),Color("#ba9660"),8))
	page_text.text = "%d / %d" % [leaf+1,ceili(catalog.size()/4.0)]
	back_page.disabled = leaf == 0
	next_page.disabled = (leaf+1)*4 >= catalog.size()
	var product := catalog[current_recipe]
	spread_art.texture = art.textures[Farm.ICON[product]]
	spread_caption.text = product
	recipe_note.text = "\n".join(recipe_steps(product))

func recipe_steps(product: String) -> PackedStringArray:
	var lines := PackedStringArray()
	if methods.has(product):
		var entry: Array = methods[product]
		for ingredient: String in entry[1]: lines.append_array(recipe_steps(ingredient))
		lines.append("%s · %s → %s" % [entry[0]," + ".join(entry[1]),product])
	return lines
