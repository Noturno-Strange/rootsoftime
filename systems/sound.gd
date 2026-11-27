extends RefCounted
var clips: Dictionary = {}

func _init() -> void:
	for key: String in ["wood","grain","water","meal","bird","coin","mill","step","unlock","care","voice","harvest"]:
		var data := PackedByteArray()
		var rng := RandomNumberGenerator.new()
		rng.seed = key.hash()
		var duration := 0.36
		data.resize(int(22050*duration)*2)
		for i in range(int(22050*duration)):
			var t := float(i)/22050.0
			var f: float = {"wood":165,"grain":430,"water":780,"meal":530,"bird":2100,"coin":1080,"mill":95,"step":72,"unlock":392,"care":440,"voice":235,"harvest":540}[key]
			var tone := sin(TAU*(f*t+sin(t*28)*0.65)) + sin(TAU*f*1.5*t)*0.3
			var noise := rng.randf_range(-0.5,0.5) if key in ["water","grain"] else 0.0
			if key == "coin": tone = sin(TAU*(950 if t<0.09 else 1430)*t)
			if key == "step": tone = rng.randf_range(-0.6,0.6)*exp(-t*28)
			if key == "mill": tone = rng.randf_range(-0.9,0.9)*(0.5+0.5*cos(t*51))
			if key in ["unlock","care","harvest"]:
				var ratio := [1.0,1.25,1.5][mini(2,int(t*10))] as float
				tone = sin(TAU*f*ratio*t)*exp(-fmod(t,0.1)*12)+0.24*sin(TAU*f*2*t)
			if key == "voice": tone = 0.6*sin(TAU*(f*t+0.2*sin(t*22)))*(1+sin(t*40))*0.5
			var value := (tone+noise)*exp(-t*13)*minf(t*220,1)*0.36
			data.encode_s16(i*2,clampi(roundi(value*23000),-32768,32767))
		var wav := AudioStreamWAV.new()
		wav.format = AudioStreamWAV.FORMAT_16_BITS
		wav.mix_rate = 22050
		wav.data = data
		clips[key] = wav

func play(world: Node2D, pos: Vector2, key: String, volume: float) -> void:
	var sound := AudioStreamPlayer2D.new()
	sound.position = pos
	sound.bus = "Ambiente" if key == "bird" else "Efeitos"
	sound.stream = clips[key]
	sound.volume_db = volume
	sound.pitch_scale = randf_range(0.94,1.06)
	sound.max_distance = 650
	world.add_child(sound)
	sound.finished.connect(sound.queue_free)
	sound.play()
