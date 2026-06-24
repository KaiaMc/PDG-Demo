extends Node2D

const FISH = preload("res://scenes/interactables/fih.tscn")

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

func _on_osc_server_message_received(address, value, time):
	if address == "/detection":
		person_found = value[0]
		PersonDetection()
	if address == "/nose:x":
		person_x = value[0]

func _process(delta):
	if Testglobal.fishgone == true:
		fish_instance.queue_free()
		fish_instance = null
		Testglobal.fishgone = false

func PersonDetection():
	if person_found == 1 and fish_instance != null:
		print("fish already spawned, returning...")
		return

	print("running person detection...")
	fish_y_spawn = rng.randf_range(200, 800)
	if person_found == 0:
		print("no one found, verifying exit...")
		await get_tree().create_timer(1.0).timeout #increase timeout later
		if fish_instance != null:
			Testglobal.fishleave = true
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
			
			# USE FOR FINAL FISH SPAWNING, COMMENTED OUT FOR DEMONSTRATING
			if person_x * viewport_size.x <= 960:
				fish_x_spawn = 10 #off screen to LEFT
			else:
				fish_x_spawn = 1920 #off screen to RIGHT
			
			fish_instance.global_position = Vector2(
			#person_x * viewport_size.x, fish_y_spawn
			#use below for actual setup !! above demonstrating only
			fish_x_spawn, fish_y_spawn
			)
			


func _on_button_pressed():
	get_tree().quit()
