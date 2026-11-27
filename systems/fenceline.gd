extends Node2D

var spans := 3
var pitch := 42.0
var seed_value := 1

func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var feet := PackedVector2Array()
	var tops := PackedVector2Array()
	for i in spans+1:
		var foot := Vector2(i*pitch,rng.randf_range(-2,2))
		feet.append(foot)
		tops.append(foot+Vector2(rng.randf_range(-2,2),-rng.randf_range(29,35)))
		draw_line(foot,foot+Vector2(14,3),Color("#59452452"),4,true)
	for i in spans:
		for height in [0.36,0.76]:
			var a := feet[i].lerp(tops[i],height)
			var b := feet[i+1].lerp(tops[i+1],height)
			draw_line(a,b,Color("#634327"),4.8,true)
			draw_line(a-Vector2(0,1.3),b-Vector2(0,1.3),Color("#b78b55"),1.5,true)
	for i in feet.size():
		var a := feet[i]
		var b := tops[i]
		draw_line(a,b,Color("#68462e"),5.8,true)
		draw_line(a+Vector2(-1,-1),b+Vector2(-1,1),Color("#bb9567"),2,true)
		for height in [0.36,0.76]:
			var joint := a.lerp(b,height)
			draw_line(joint-Vector2(2.6,-1),joint+Vector2(2.6,-1),Color("#453b2d"),1.2,true)
		for blade in 7:
			var root := a+Vector2(rng.randf_range(-6,6),1)
			draw_line(root,root+Vector2(rng.randf_range(-4,4),-rng.randf_range(2,6)),Color("#707435"),1.3,true)
