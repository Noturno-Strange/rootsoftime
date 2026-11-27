extends RefCounted

const Weather = preload("res://systems/weather.gd")
const ORDER_BONUS := 3
# Receitas com mais etapas ou misturas rendem mais na feira.
const ARTISAN_PRICES := {"Arroz com pequi":10,"Creme de acerola":8,"Angu":7, "Pamonha":7, "Creme de manga":8, "Broa de milho":10,
	"Baião da vila":12, "Farinha de mandioca":13, "Beiju":13}

func sale_price(item: String) -> int:
	return ARTISAN_PRICES.get(item, 5 if item in MEALS else 0)

func market_payout(item: String) -> int:
	var price := sale_price(item)
	if item == ORDERS[int(state.order)] and state.delivered + 1 >= state.quota:
		price += ORDER_BONUS
	return price

const FRUIT_SPOTS := {"pequi_drop":"Pequi", "lime_drop":"Limão", "acerola_drop":"Acerola"}
const FALL_INTERVAL := {"pequi_drop":32.0,"lime_drop":24.0,"acerola_drop":20.0}
const NEIGHBORS := {
	"gardener":"No pomar a oeste das casas, procure os frutos maduros que caíram.",
	"weaver":"Eu cuido das cestarias. Leve um fruto por vez ou divida o transporte com a turma.",
	"cook":"Aqui fazemos arroz com pequi. Junte arroz cru e pequi na bancada e leve a mistura ao fogão."
}
const HARVEST_LIMIT := 10

func unwell(id: int) -> bool:
	return int(state.effort.get(id,0)) >= HARVEST_LIMIT

func sore(id: int) -> bool:
	return int(state.effort.get(id,0)) == HARVEST_LIMIT + 1

func record_harvest(id: int, from_bed: bool = false) -> void:
	if unwell(id): return
	var count := int(state.effort.get(id,0))+1
	state.effort[id] = count+1 if count == HARVEST_LIMIT and from_bed else count

const CROPS := ["Milho", "Mandioca", "Arroz", "Feijão"]
const GROW := [14, 20, 12, 16]
const MEALS := ["Angu", "Milho cozido", "Mandioca cozida", "Feijão de panela", "Arroz branco", "Doce de manga", "Ovos mexidos", "Leite quente", "Broa de milho", "Pamonha", "Beiju", "Baião da vila", "Creme de manga", "Arroz com pequi", "Sumo de limão", "Suco de acerola", "Geleia de acerola", "Creme de acerola"]
const ORDERS := ["Angu","Pamonha","Baião da vila","Broa de milho","Doce de manga"]
var participants := 1
const BLENDS := {"Arroz|Pequi":"Arroz cru com pequi","Acerola|Leite":"Leite com acerola","Arroz branco|Feijão de panela":"Arroz e feijão", "Fubá|Ovos":"Massa de broa", "Leite|Manga":"Leite com manga"}
const ICON := {
 "Adubo":"soil",
 "Pequi":"pequi_fruit","Limão":"lime_fruit","Acerola":"acerola_fruit",
 "Arroz cru com pequi":"pequi_rice","Arroz com pequi":"pequi_rice","Sumo de limão":"lime_drink",
 "Suco de acerola":"acerola_fruit","Geleia de acerola":"acerola_jam","Leite com acerola":"food_16","Creme de acerola":"food_29",
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
const TOOL_NAMES := ["Enxada","Sementes","Regador","Cesto"]
const UPGRADE_COST := [0,10,25]

func water_capacity() -> int:
	return 2*int(state.levels[2])

func tend_row(index: int, stage: int) -> void:
	var reach := int(state.levels[stage])
	for i in range(index,mini(index+reach,(index/4+1)*4)):
		if state.plots[i].stage == stage: state.plots[i].stage = stage+1

const LAND_PRICE := 35
const STOCK_PRICE := {"farm_cat":5,"farm_hen":8,"farm_pig":12}
const STOCK_NAME := {"farm_cat":"gato","farm_hen":"galinha","farm_pig":"porco"}
const STALL_NAMES := {"market":"Dona Dica · cozinha", "fruit_stall":"Bento · frutas","grain_stall":"Luzia · roça","dairy_stall":"Zeca · ovos e leite"}
const OFFERS := {"fruit_stall":{"Manga":3,"Pequi":4,"Limão":3,"Acerola":3},
	"grain_stall":{"Milho":2,"Arroz":2,"Feijão":3,"Mandioca":3,"Fubá":4},
	"dairy_stall":{"Ovos":4,"Leite":4}}

func homestead_action(id: int, target: String) -> String:
	if target == "homestead":
		if state.land or state.coins < LAND_PRICE: return ""
		state.coins -= LAND_PRICE
		state.land = true
		return "Sítio adquirido · quatro canteiros liberados!"
	if not state.land: return ""
	if not state.stock.has(target):
		if state.coins < STOCK_PRICE[target]: return ""
		state.coins -= STOCK_PRICE[target]
		state.stock[target] = 0.0
		return "Chegou ao sítio: %s!" % STOCK_NAME[target]
	if state.time < state.stock[target]: return ""
	var hand: String = hands.get(id,"")
	match target:
		"farm_cat":
			state.effort.erase(id)
		"farm_hen":
			if hand != "Milho": return ""
			hands[id] = "Ovos"
		"farm_pig":
			if hand not in CROPS: return ""
			hands[id] = "Adubo"
	state.stock[target] = state.time + 35.0
	return {"farm_cat":"Carinho no gato · disposição recuperada.","farm_hen":"Galinha alimentada · ovos no cesto.","farm_pig":"Chiqueiro cuidado · adubo no cesto."}[target]

func homestead_prompt(id: int, target: String) -> String:
	if target == "homestead": return "Sítio da vila · quatro canteiros" if state.land else "Comprar sítio · %d/%d moedas" % [state.coins,LAND_PRICE]
	if not state.land: return "Compre o sítio na placa"
	if not state.stock.has(target): return "Trazer %s · %d/%d moedas" % [STOCK_NAME[target],state.coins,STOCK_PRICE[target]]
	if state.time < state.stock[target]: return "%s descansando · %d s" % [str(STOCK_NAME[target]).capitalize(),ceili(state.stock[target]-state.time)]
	return {"farm_cat":"Acariciar o gato","farm_hen":"Dar milho à galinha e recolher ovos","farm_pig":"Dar uma colheita ao porco e recolher adubo"}[target]

const TRAY_CAPACITY := 4
var recipes: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/recipes.json"))
var state: Dictionary
var hands: Dictionary = {}

func _init() -> void:
	state = {"version":5, "land":false,"stock":{}, "fallen":{"pequi_drop":0.0,"lime_drop":0.0,"acerola_drop":0.0}, "effort":{}, "levels":[1,1,1,1], "water":2, "tray":[], "served_item":"", "time":0.0, "plots":[], "jobs":{}, "storage":[], "coins":0, "sales":0, "served":0, "book":[], "fruit":0.0, "family":"home", "escort":0, "bell":0.0, "trips":0, "upgrade":false, "hen":0.0, "cow":0.0, "bowl":"", "order":0, "delivered":0, "quota":1, "feasts":0}
	for i in range(12):
		state.plots.append({"stage":0 if i<4 or i>=8 else (4 if i==4 else 3), "crop":i % CROPS.size(), "ready":0.0 if i<5 else float(4*i)})

func tick(delta: float) -> void:
	var rain_at: float = state.time + Weather.seconds_until_rain(state.time)
	state.time += delta
	for p: Dictionary in state.plots:
		if p.stage == 2 and state.time >= rain_at:
			p.stage = 3
			p.ready = rain_at + GROW[int(p.crop)]
		if p.stage == 3 and state.time >= p.ready:
			p.stage = 4

func release(id: int) -> void:
	var hand: String = hands.get(id, "")
	if hand != "":
		state.storage.append(hand)
	hands.erase(id)
	state.effort.erase(id)
	if state.escort == id:
		state.family = "home" if state.family == "out" else "school"
		state.escort = 0

func act(id: int, target: String, tool: int = 0) -> String:
	var hand: String = hands.get(id, "")
	if target == "homestead" or STOCK_PRICE.has(target): return homestead_action(id,target)
	if OFFERS.has(target):
		if not OFFERS[target].has(hand): return ""
		var price: int = OFFERS[target][hand]
		state.coins += price
		state.sales += 1
		hands[id] = ""
		return "%s vendido · +%d moedas" % [hand,price]
	if FRUIT_SPOTS.has(target):
		if hand != "" or state.time < state.fallen[target]: return ""
		hands[id] = FRUIT_SPOTS[target]
		state.fallen[target] = state.time + FALL_INTERVAL[target]
		record_harvest(id)
		return "%s recolhido do chão." % hands[id]
	if NEIGHBORS.has(target): return NEIGHBORS[target]
	if target == "healer":
		if unwell(id):
			state.effort.erase(id)
			return "Pajé · O cuidado terminou. Você já pode voltar ao trabalho."
		return "Pajé · Seja bem-vindo. Se sentir mal-estar na lida, venha descansar aqui."
	if target.begins_with("plot"):
		var index := target.trim_prefix("plot").to_int()
		if index < 0 or index >= state.plots.size() or (index >= 8 and not state.land): return ""
		var p: Dictionary = state.plots[index]
		if hand == "Adubo" and p.stage == 3:
			p.stage = 4
			hands[id] = ""
			return "Terra adubada · colheita pronta."
		match int(p.stage):
			0: tend_row(index,0); return "Terra preparada."
			1: tend_row(index,1); return "Sementes de %s na terra." % CROPS[int(p.crop)].to_lower()
			2:
				if state.water <= 0: return ""
				state.water -= 1
				p.stage = 3
				p.ready = state.time + GROW[int(p.crop)]
				return "Canteiro regado."
			4:
				if hand.is_empty():
					hands[id] = CROPS[int(p.crop)]
					p.stage = 0
					for extra in range(1,int(state.levels[3])): state.storage.append(hands[id])
					record_harvest(id,true)
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
		"teacher":
			match str(state.family):
				"school":
					if state.time >= state.bell: return "Profª Célia · A aula terminou! Pode buscar a turma na porta."
					return "Profª Célia · Estamos em aula. O sino toca em %d s." % ceili(state.bell-state.time)
				"out": return "Profª Célia · A turma chegou? Vamos nos encontrar na entrada."
				"back": return "Profª Célia · Até amanhã, crianças! Boa volta para casa."
			return "Profª Célia · Bom dia! Pode trazer as crianças quando estiverem prontas."
		"well":
			if tool != 2 or state.water == water_capacity(): return ""
			state.water = water_capacity()
			return "Regador abastecido no poço."
		"warehouse":
			if tool < 0 or tool >= TOOL_NAMES.size(): return ""
			var level := int(state.levels[tool])
			if level >= 3 or state.coins < UPGRADE_COST[level]: return ""
			state.coins -= UPGRADE_COST[level]
			state.levels[tool] = level+1
			return "%s · nível %d" % [TOOL_NAMES[tool],level+1]
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
				return "%s na mesa compartilhada." % hand
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
			var payout := market_payout(hand)
			if payout > 0:
				state.coins += payout
				state.sales += 1
				hands[id] = ""
				if hand == ORDERS[int(state.order)]:
					state.delivered += 1
					if state.delivered >= state.quota:
						state.order = (int(state.order)+1)%ORDERS.size()
						state.delivered = 0
						state.quota = clampi(ceili(participants/2.0),1,3)
						if state.order == 0:
							state.feasts += 1
							return "Festa da colheita! Encomenda completa · +%d moedas" % payout
						return "Encomenda completa · +%d moedas" % payout
					return "Entrega parcial · %d/%d · +%d moedas" % [state.delivered,state.quota,payout]
				return "Venda na feira · +%d moedas" % payout
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

func prompt(id: int, target: String, tool: int = 0) -> String:
	var hand: String = hands.get(id, "")
	if target == "homestead" or STOCK_PRICE.has(target): return homestead_prompt(id,target)
	if OFFERS.has(target):
		if OFFERS[target].has(hand): return "%s · vender %s por %d" % [STALL_NAMES[target],hand,OFFERS[target][hand]]
		return "%s · compra %s" % [STALL_NAMES[target],", ".join(OFFERS[target].keys())]
	if FRUIT_SPOTS.has(target):
		if state.time < state.fallen[target]: return "Aguardando outro fruto cair"
		return "Esvazie o cesto para recolher" if hand != "" else "Recolher %s do chão" % str(FRUIT_SPOTS[target]).to_lower()
	if NEIGHBORS.has(target): return {"gardener":"Conversar com a horticultora","weaver":"Conversar com o artesão","cook":"Conversar com a cozinheira"}[target]
	if target == "healer": return "Receber cuidados do pajé" if unwell(id) else "Conversar com o pajé"
	if target.begins_with("plot"):
		var index := target.trim_prefix("plot").to_int()
		if index >= 8 and not state.land: return "Terreno à venda · consulte a placa"
		var p: Dictionary = state.plots[index]
		if hand == "Adubo" and p.stage == 3: return "Adubar para antecipar a colheita"
		if p.stage == 2 and Weather.seconds_until_rain(state.time) <= 15:
			return "Regar ou aguardar a chuva" if state.water > 0 else "Aguarde a chuva ou busque água"
		if p.stage == 2 and state.water == 0: return "Busque água no poço"
		return ["Preparar a terra", "Plantar " + CROPS[int(p.crop)].to_lower(), "Regar o canteiro", "Cultivo em crescimento", "Colher " + CROPS[int(p.crop)].to_lower()][int(p.stage)]
	if recipes.has(target):
		if state.jobs.has(target):
			var job: Dictionary = state.jobs[target]
			return ("Retirar " if state.time >= job.ready else "Preparando ") + str(job.product).to_lower()
		if recipes[target].has(hand): return "Preparar " + str(recipes[target][hand][0]).to_lower()
		return {"mill":"Moinho · milho", "press":"Prensa · massa ralada", "stove":"Fogão a lenha", "wash":"Lavar mandioca", "grater":"Ralar milho ou mandioca lavada", "sieve":"Peneirar massa prensada", "pan":"Chapa · ovos, leite ou massa peneirada", "oven":"Forno · massa de milho ou de broa"}[target]
	match target:
		"teacher": return "Conversar com a professora Célia"
		"well": return "Encher regador no poço · %d/%d" % [state.water,water_capacity()] if state.water < water_capacity() else "Regador cheio"
		"warehouse":
			var level := int(state.levels[clampi(tool,0,3)])
			var name: String = TOOL_NAMES[clampi(tool,0,3)]
			if level == 3: return "%s · nível máximo" % name
			return "Melhorar %s · Nv. %d → %d · %d moedas" % [name,level,level+1,UPGRADE_COST[level]]
		"hen": return "Recolher ovos"
		"cow": return "Tirar leite"
		"mix": return "Bancada · " + (str(state.bowl) if state.bowl != "" else "acrescentar ingrediente")
		"home": return "Chegar em casa" if state.family == "back" else "Chamar as crianças para a escola"
		"school": return "Buscar as crianças" if state.family == "school" else "Chegar à escola"
		"table": return "Servir a refeição"
		"orchard": return "Colher manga"
		"tray":
			if hand == "":
				return "Retirar " + str(state.tray.back()) if not state.tray.is_empty() else "Mesa compartilhada vazia"
			return "Mesa compartilhada cheia" if state.tray.size() >= TRAY_CAPACITY else "Colocar " + hand
		"storage": return "Guardar " + hand if hand != "" else "Depósito · %d itens" % state.storage.size()
		"market":
			if hand == "":
				return "Restaurar banco · 15 moedas" if not state.upgrade else "Dona Dica · pratos e farinha"
			var payout := market_payout(hand)
			if payout == 0: return "A feira compra pratos e farinha"
			var action := "Entregar" if hand == ORDERS[int(state.order)] else "Vender"
			return "%s %s · %d moedas" % [action, hand, payout]
	return ""

func required_tool(target: String) -> int:
	if target == "well": return 2
	if not target.begins_with("plot"): return -1
	var index := target.trim_prefix("plot").to_int()
	if index < 0 or index >= state.plots.size(): return -1
	return [0,1,2,-1,3][int(state.plots[index].stage)]
