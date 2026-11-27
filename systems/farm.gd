extends RefCounted

const CROPS := ["Milho", "Mandioca", "Arroz", "Feijão"]
const GROW := [14, 20, 12, 16]
const MEALS := ["Angu", "Milho cozido", "Mandioca cozida", "Feijão de panela", "Arroz branco", "Doce de manga", "Ovos mexidos", "Leite quente", "Broa de milho", "Pamonha", "Beiju", "Baião da vila", "Creme de manga"]
const ORDERS := ["Angu","Pamonha","Baião da vila","Broa de milho","Doce de manga"]
var participants := 1
const BLENDS := {"Arroz branco|Feijão de panela":"Arroz e feijão", "Fubá|Ovos":"Massa de broa", "Leite|Manga":"Leite com manga"}
const ICON := {
 "Milho": "food_00",
 "Mandioca": "food_01",
 "Arroz": "food_02",
 "Feijão": "food_03",
 "Manga": "food_04",
 "Ovos": "food_05",
 "Leite": "food_06",
 "Fubá": "food_07",
 "Mandioca lavada": "food_08",
 "Massa ralada": "food_09",
 "Massa prensada": "food_10",
 "Massa peneirada": "food_11",
 "Farinha de mandioca": "food_12",
 "Massa de milho": "food_13",
 "Massa de broa": "food_14",
 "Arroz e feijão": "food_15",
 "Leite com manga": "food_16",
 "Angu": "food_17",
 "Milho cozido": "food_18",
 "Mandioca cozida": "food_19",
 "Feijão de panela": "food_20",
 "Arroz branco": "food_21",
 "Doce de manga": "food_22",
 "Ovos mexidos": "food_23",
 "Leite quente": "food_24",
 "Broa de milho": "food_25",
 "Pamonha": "food_26",
 "Beiju": "food_27",
 "Baião da vila": "food_28",
 "Creme de manga": "food_29"
}
const TRAY_CAPACITY := 4
var recipes: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/recipes.json"))
var state: Dictionary
var hands: Dictionary = {}

func _init() -> void:
	state = {"version":2, "tray":[], "served_item":"", "time":0.0, "plots":[], "jobs":{}, "storage":[], "coins":0, "sales":0, "served":0, "book":[], "fruit":0.0, "family":"home", "escort":0, "bell":0.0, "trips":0, "upgrade":false, "hen":0.0, "cow":0.0, "bowl":"", "order":0, "delivered":0, "quota":1, "feasts":0}
	for i in range(8):
		state.plots.append({"stage":0 if i<4 else (4 if i==4 else 3), "crop":i % CROPS.size(), "ready":0.0 if i<5 else float(4*i)})

func tick(delta: float) -> void:
	state.time += delta
	for p: Dictionary in state.plots:
		if p.stage == 3 and state.time >= p.ready:
			p.stage = 4

func release(id: int) -> void:
	var hand: String = hands.get(id, "")
	if hand != "":
		state.storage.append(hand)
	hands.erase(id)
	if state.escort == id:
		state.family = "home" if state.family == "out" else "school"
		state.escort = 0

func act(id: int, target: String) -> String:
	var hand: String = hands.get(id, "")
	if target.begins_with("plot"):
		var index := target.trim_prefix("plot").to_int()
		if index < 0 or index >= state.plots.size(): return ""
		var p: Dictionary = state.plots[index]
		match int(p.stage):
			0: p.stage = 1; return "Terra preparada."
			1: p.stage = 2; return "Sementes de %s na terra." % CROPS[int(p.crop)].to_lower()
			2: p.stage = 3; p.ready = state.time + GROW[int(p.crop)]; return "Canteiro regado."
			4:
				if hand.is_empty():
					hands[id] = CROPS[int(p.crop)]
					p.stage = 0
					return "Colheita no cesto."
		return ""
	if recipes.has(target):
		if state.jobs.has(target):
			var job: Dictionary = state.jobs[target]
			if state.time < job.ready or not hand.is_empty(): return ""
			hands[id] = job.product
			if not state.book.has(job.product): state.book.append(job.product)
			state.jobs.erase(target)
			return "%s no cesto." % hands[id]
		if not recipes[target].has(hand): return ""
		var recipe: Array = recipes[target][hand]
		state.jobs[target] = {"product":recipe[0], "ready":state.time + recipe[1]}
		hands[id] = ""
		return "Preparo iniciado."
	match target:
		"hen", "cow":
			if hand.is_empty() and state.time >= state[target]:
				hands[id] = "Ovos" if target == "hen" else "Leite"
				state[target] = state.time + 28.0
				return "Produto recolhido."
		"mix":
			var first: String = state.bowl
			if first == "" and hand != "":
				state.bowl = hand
				hands[id] = ""
				return "Ingrediente na tigela."
			if first != "" and hand == "":
				hands[id] = first
				state.bowl = ""
				return "Ingrediente retirado."
			var ingredients := [first,hand]
			ingredients.sort()
			var pair := "|".join(ingredients)
			if BLENDS.has(pair):
				hands[id] = BLENDS[pair]
				state.bowl = ""
				return "Ingredientes misturados."
		"tray":
			if hand != "" and state.tray.size() < TRAY_CAPACITY:
				state.tray.append(hand)
				hands[id] = ""
				return "%s na bandeja." % hand
			if hand == "" and not state.tray.is_empty():
				hands[id] = state.tray.pop_back()
				return "%s no cesto." % hands[id]
		"storage":
			if not hand.is_empty():
				state.storage.append(hand)
				hands[id] = ""
				return "Guardado no depósito."
			if not state.storage.is_empty():
				hands[id] = state.storage.pop_back()
				return "Retirado do depósito."
		"orchard":
			if hand.is_empty() and state.time >= state.fruit:
				hands[id] = "Manga"
				state.fruit = state.time + 35
				return "Manga colhida."
		"market":
			if MEALS.has(hand) or hand == "Farinha de mandioca":
				state.coins += 5
				state.sales += 1
				hands[id] = ""
				if hand == ORDERS[int(state.order)]:
					state.delivered += 1
					if state.delivered >= state.quota:
						state.order = (int(state.order)+1)%ORDERS.size()
						state.delivered = 0
						state.quota = clampi(ceili(participants/2.0),1,3)
						state.coins += 3
						if state.order == 0:
							state.feasts += 1
							return "Festa da colheita! A vila se reúne na feira."
						return "Encomenda completa · +8 moedas"
				return "Venda na feira · +5 moedas"
			if hand.is_empty() and state.coins >= 15 and not state.upgrade:
				state.coins -= 15
				state.upgrade = true
				return "Banco da praça restaurado!"
		"table":
			if MEALS.has(hand) and state.family == "home":
				hands[id] = ""
				state.served_item = hand
				state.served += 1
				state.family = "eating"
				state.bell = state.time + 4
				return "Refeição servida para as crianças."
		"home":
			if state.family == "home" or (state.family == "eating" and state.time >= state.bell):
				state.escort = id
				state.family = "out"
				return "As crianças acompanham você até a escola."
			if state.family == "back" and state.escort == id:
				state.escort = 0
				state.family = "home"
				state.trips += 1
				return "As crianças chegaram em casa."
		"school":
			if state.family == "out" and state.escort == id:
				state.family = "school"
				state.escort = 0
				state.bell = state.time + 24
				return "A aula começou."
			if state.family == "school" and state.time >= state.bell:
				state.family = "back"
				state.escort = id
				return "Hora de voltar para casa."
	return ""

func prompt(id: int, target: String) -> String:
	var hand: String = hands.get(id, "")
	if target.begins_with("plot"):
		var p: Dictionary = state.plots[target.trim_prefix("plot").to_int()]
		return ["Preparar a terra", "Plantar " + CROPS[int(p.crop)].to_lower(), "Regar o canteiro", "Cultivo em crescimento", "Colher " + CROPS[int(p.crop)].to_lower()][int(p.stage)]
	if recipes.has(target):
		if state.jobs.has(target):
			var job: Dictionary = state.jobs[target]
			return ("Retirar " if state.time >= job.ready else "Preparando ") + str(job.product).to_lower()
		if recipes[target].has(hand): return "Preparar " + str(recipes[target][hand][0]).to_lower()
		return {"mill":"Moinho · milho", "press":"Prensa · massa ralada", "stove":"Fogão a lenha", "wash":"Lavar mandioca", "grater":"Ralar milho ou mandioca lavada", "sieve":"Peneirar massa prensada", "pan":"Chapa · ovos, leite ou massa peneirada", "oven":"Forno · massa de milho ou de broa"}[target]
	match target:
		"hen": return "Recolher ovos"
		"cow": return "Tirar leite"
		"mix": return "Bancada · " + (str(state.bowl) if state.bowl != "" else "acrescentar ingrediente")
		"home": return "Chegar em casa" if state.family == "back" else "Chamar as crianças para a escola"
		"school": return "Buscar as crianças" if state.family == "school" else "Chegar à escola"
		"table": return "Servir a refeição"
		"orchard": return "Colher manga"
		"tray":
			if hand == "":
				return "Retirar " + str(state.tray.back()) if not state.tray.is_empty() else "Bandeja vazia"
			return "Bandeja cheia" if state.tray.size() >= TRAY_CAPACITY else "Colocar " + hand
		"storage": return "Guardar " + hand if hand != "" else "Depósito · %d itens" % state.storage.size()
		"market": return "Restaurar banco · 15 moedas" if hand == "" and not state.upgrade else "Entregar prato na feira"
	return ""
