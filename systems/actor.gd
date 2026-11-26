extends CharacterBody2D
var art: RefCounted
var figure: Sprite2D
var cargo: Sprite2D
var step := 0.0
var last_dir := Vector2.DOWN
var child := false
var female := false
var eating := false
var activity := ""
var action_time := 0.0
var held := ""
var facing_key := ""

func setup(atlas: RefCounted, little: bool = false) -> void:
	art = atlas
	child = little
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 0
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 7 if little else 9
	shape.shape = circle
	add_child(shape)
	figure = atlas.sprite("child" if little else "farmer", 49 if little else 68)
	add_child(figure)
	cargo = atlas.sprite("basket",22)
	cargo.visible = false
	cargo.position = Vector2(11,-15)
	add_child(cargo)

func pose(motion: Vector2, delta: float, item: String) -> void:
	var moving := motion.length() > 5
	if moving:
		last_dir = motion.normalized()
		step += delta * motion.length() * 0.055
	var key := "child" if child else "farmer"
	if child and moving: key = "lia"+str(int(step)%4)
	if child and eating: key = "eat"+str(int(Time.get_ticks_msec()/280.0)%4)
	if not child and (moving or last_dir.y < -0.35):
		key = ("back" if last_dir.y < -0.35 else "step") + str(int(step)%4 if moving else 1)
	var height := 49.0 if child else 68.0
	if female: key = "woman"+str(int(step)%4 if moving else 1)
	if action_time > 0 and not child:
		action_time = maxf(0,action_time-delta)
		var frame := clampi(int((0.68-action_time)*4/0.68),0,3)
		if not female: key = activity + str(frame)
		height *= [1.0,0.87,0.74,0.94][frame] if activity == "pick" else 1.0
	if child and eating: height = 38
	if facing_key != key:
		art.paint(figure,key,height)
		facing_key = key
	figure.flip_h = last_dir.x < -0.12
	figure.position.y = -absf(sin(step))*1.4 if moving else 0
	if held != item:
		held = item
		cargo.visible = held != ""
		if cargo.visible:
			art.paint(cargo,preload("res://systems/farm.gd").ICON.get(item,"meal"),22)
	cargo.position.x = -12 if figure.flip_h else 12
