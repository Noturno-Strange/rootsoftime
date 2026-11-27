extends CharacterBody2D
const MALE_RIM := [Vector2(10.86,-51.89), Vector2(2.80,-51.24), Vector2(6.17,-50.86), Vector2(10.10,-51.98)]
const FEMALE_RIM := [Vector2(12.28,-51.68), Vector2(4.30,-50.11), Vector2(6.73,-50.11), Vector2(9.16,-50.49)]
var art: RefCounted
var figure: Sprite2D
var cargo: Sprite2D
var step := 0.0
var last_dir := Vector2.DOWN
var child := false
var female := false
var kid_index := 0
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
	circle.radius = 8 if little else 11
	shape.shape = circle
	add_child(shape)
	figure = atlas.sprite("child" if little else "farmer", 66 if little else 92)
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
	var height := 66.0 if child else 92.0
	if female: key = "woman"+str(int(step)%4 if moving else 1)
	if action_time > 0 and not child:
		action_time = maxf(0,action_time-delta)
		var frame := clampi(int((0.68-action_time)*4/0.68),0,3)
		if not female: key = activity + str(frame)
		height *= [1.0,0.87,0.74,0.94][frame] if activity == "pick" else 1.0
	if child:
		key = "kid%d%d" % [kid_index,int(step)%4 if moving else 1]
		if eating and kid_index == 0: key = "eat"+str(int(Time.get_ticks_msec()/280.0)%4)
		if eating and kid_index == 0: height = 51
	elif item != "" and action_time <= 0:
		key = ("load_f" if female else "load_m")+str(int(step)%4 if moving else 1)
	if facing_key != key:
		art.paint(figure,key,height)
		facing_key = key
	figure.flip_h = last_dir.x < -0.12
	figure.position.y = -absf(sin(step))*1.4 if moving else 0
	if held != item:
		held = item
		cargo.visible = held != ""
		if cargo.visible:
			var icon: String = preload("res://systems/farm.gd").ICON[item]
			var tex: Texture2D = art.textures[icon]
			art.paint(cargo,icon,minf(12,24*tex.get_height()/tex.get_width()))
	cargo.visible = item != "" and action_time <= 0
	var frame_index := int(step)%4 if moving else 1
	var rim: Vector2 = FEMALE_RIM[frame_index] if female else MALE_RIM[frame_index]
	cargo.position = Vector2(-rim.x if figure.flip_h else rim.x,rim.y+3.5+figure.position.y)
