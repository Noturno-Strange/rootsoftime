extends RefCounted

const PATH := "user://vila.save"

static func valid(s: Variant, defaults: Dictionary) -> bool:
	if not s is Dictionary: return false
	if s.get("version") == 1:
		s.version = 2
		s.tray = []
		s.served_item = ""
	if s.get("version") != 2: return false
	for k: String in defaults:
		if not s.has(k) or typeof(s[k]) != typeof(defaults[k]): return false
	if s.order < 0 or s.order >= preload("res://systems/farm.gd").ORDERS.size(): return false
	if s.family not in ["home","school","eating"] or s.escort != 0: return false
	if s.quota < 1 or s.quota > 3 or s.delivered < 0 or s.delivered >= s.quota: return false
	if s.tray.size() > 4: return false
	for items: Array in [s.storage,s.book,s.tray]:
		for item: Variant in items:
			if not item is String: return false
	if s.plots.size() != defaults.plots.size(): return false
	for p: Variant in s.plots:
		if not p is Dictionary or not p.get("stage") is int or not p.get("crop") is int or not p.get("ready") is float: return false
		if p.stage < 0 or p.stage > 4 or p.crop < 0 or p.crop > 3: return false
	for k: Variant in s.jobs:
		var j: Variant = s.jobs[k]
		if k not in ["mill","stove","press","oven","pan","wash","grater","sieve"] or not j is Dictionary or not j.get("product") is String or not j.get("ready") is float: return false
	return true

static func recover(defaults: Dictionary) -> Dictionary:
	for path: String in [PATH, PATH + ".bak"]:
		if FileAccess.file_exists(path):
			var f := FileAccess.open(path, FileAccess.READ)
			if f:
				var data: Variant = f.get_var(false)
				if valid(data, defaults): return data
	return defaults

static func write(farm: RefCounted) -> bool:
	var saved: Dictionary = farm.state.duplicate(true)
	for item: String in farm.hands.values():
		if item != "": saved.storage.append(item)
	if saved.escort != 0:
		saved.family = "home" if saved.family == "out" else "school"
		saved.escort = 0
	var out := FileAccess.open(PATH + ".tmp", FileAccess.WRITE)
	if not out: return false
	out.store_var(saved)
	out.flush()
	var ok := out.get_error() == OK
	out.close()
	if not ok: return false
	var dir := DirAccess.open("user://")
	if dir.file_exists("vila.save"):
		var prev := FileAccess.open(PATH, FileAccess.READ)
		if prev and valid(prev.get_var(false), farm.state):
			if DirAccess.copy_absolute(PATH, PATH + ".bak") != OK: return false
	return dir.rename("vila.save.tmp", "vila.save") == OK
