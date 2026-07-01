extends Node3D

const FISH = preload("res://scenes/interactables/3Dfish.tscn")
@onready var camera = $Camera3D
@onready var random_fish = $RandomFish
@onready var fish_school = $FishSchool
@onready var timer = $Timer

var screen_width = 1920
var screen_height = 1080
var viewport_size

var person_x = 0 #determine where exactly the person is standing across the x-axis. use for fish x-axis first swim position
var rng = RandomNumberGenerator.new()

#0 is no one, 1 is someone
var person_found = 0

var fish_instance = null
var fish_x_spawn = 100
var fish_y_spawn = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_size = get_viewport().get_visible_rect().size

func screen_to_world(screen_pos: Vector2) -> Vector3:
	var world_pos = camera.project_position(screen_pos, 0.0)
	return world_pos

func _on_osc_server_message_received(address, value, time):
	if address == "/detection":
		person_found = value[0]
		PersonDetection()
	if address == "/nose:x":
		person_x = value[0]
	if address == "/wave":
		#FishTwirl() (working)
		pass
		

func FishTwirl():
	pass

func _process(delta):
	if Global.fishgone == true:
		fish_instance.queue_free()
		fish_instance = null
		Global.fishgone = false
		print("fish deleted")

func PersonDetection():
	if person_found == 1 and fish_instance != null:
		print("fish already spawned, returning...")
		return

	print("running person detection...")

	var top_world = screen_to_world(Vector2(0, 0))
	var bottom_world = screen_to_world(Vector2(0, viewport_size.y))
	fish_y_spawn = rng.randf_range(
		bottom_world.y + 5,
		top_world.y -5
	)

	if person_found == 0:
		print("no one found!")
		await get_tree().create_timer(1.0).timeout #increase timeout later
		if fish_instance != null and person_found == 0:
			Global.fishleave = true
			print("no one found, removing fish...")
		else:
			print("exit not verified, returning...")
		return
	else:
		print ("person detected, verifying...")
		await get_tree().create_timer(1.0).timeout #increase timeout later
		if person_found == 0:
			print ("can not verify person. Returning...")
			return
		else:
			print("person verified, adding fish...")
			if fish_instance == null:
				fish_instance = FISH.instantiate()
				add_child(fish_instance)
			
			var left_world = screen_to_world(Vector2(0, viewport_size.y / 2))
			var right_world = screen_to_world(Vector2(viewport_size.x, viewport_size.y / 2))
			if person_x * viewport_size.x <= viewport_size.x / 2:
				fish_x_spawn = left_world.x - 2.0
				Global.spawnleft = true
			else:
				fish_x_spawn = right_world.x + 2.0
				Global.spawnright = true
			
			fish_instance.global_position = Vector3(
			fish_x_spawn, fish_y_spawn, 0
			)
			

func _on_button_pressed():
	get_tree().quit()

func _on_timer_timeout():
	var spawnchance = rng.randi_range(1, 10)
	if spawnchance <= 4:
		await run_school_tween()
	elif spawnchance >= 7:
		await run_random_fish_tween()
	else:
		print("no fish!")
		timer.start()
	
func run_school_tween():
	var original_pos = fish_school.position
	var tween = get_tree().create_tween()
	tween.tween_property(
		fish_school,
		"position",
		Vector3(39, original_pos.y, original_pos.z),
		6.0
	)
	await tween.finished
	fish_school.position = original_pos
	timer.start()

func run_random_fish_tween():
	var original_pos = random_fish.position
	var tween = get_tree().create_tween()
	tween.tween_property(
		random_fish,
		"position",
		Vector3(-150, original_pos.y, original_pos.z),
		11.0
	)
	await tween.finished
	random_fish.position = original_pos
	timer.start()
