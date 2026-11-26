extends Node

var music := AudioStreamPlayer.new()

func _ready() -> void:
	for name: String in ["Música","Ambiente","Efeitos"]:
		if AudioServer.get_bus_index(name) >= 0: continue
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count-1,name)
	music.bus = "Música"
	var loop: AudioStreamOggVorbis = preload("res://assets/terreiro.ogg")
	loop.loop = true
	music.stream = loop
	music.volume_db = -9
	add_child(music)
	if AudioServer.get_driver_name() != "Dummy": music.play()

func _exit_tree() -> void:
	music.stop()
	music.stream = null
