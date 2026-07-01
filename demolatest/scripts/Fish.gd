extends Node3D

@onready var wander_points = get_parent().get_node("WanderPoints").get_children()
@export var wander_direction : Node3D
@export var swim_speed := 2.0
@onready var animation_player = $AnimationPlayer

var x_location
var y_location
var current_point := 0
var direction := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("fishSwim")
	var screen_x = get_parent().person_x * get_parent().viewport_size.x
	var world_pos = get_parent().screen_to_world(
		Vector2(screen_x, get_parent().viewport_size.y / 2)
	)
	x_location = world_pos.x
	y_location = get_parent().fish_y_spawn
	
	var enterTween = get_tree().create_tween()
	enterTween.tween_property(self, "position", Vector3(x_location, y_location, 0), 4.0)
	await enterTween.finished
	fish_wander()

func _process(delta):
	if Global.fishleave == true:
		fish_leave()
		Global.fishleave = false
	if Global.spawnleft == true: 
		rotation.y = deg_to_rad(-90)
		Global.spawnleft = false 
	if Global.spawnright == true: 
		rotation.y = deg_to_rad(90) 
		Global.spawnright = false

func face_target(target: Vector3): 
	
	## old code
	## animation_player.play("turn")
	## await animation_player.finished ? idk if this will work
	#var move_direction = target - global_position 
	#if move_direction.x < 0: 
		#rotation.y = deg_to_rad(-270) 
	#else:
		#rotation.y = deg_to_rad(90) 
	
	var move_direction = target - global_position 
	if move_direction.x < 0: 
		self.scale = Vector3(1, 1, 1)
		self.rotation.z = deg_to_rad(0)
		animation_player.play("FishTurnR")
		print("playing right turn")
		await animation_player.animation_finished
		if rotation.y < 0:
			rotation.y = deg_to_rad(180)
		else:
			pass
	else: 
		self.scale = Vector3(-1, -1, -1)
		self.rotation.z = deg_to_rad(180)
		animation_player.play("FishTurnL")
		print("playing left turn")
		await animation_player.animation_finished
		if rotation.y > 0:
			rotation.y = deg_to_rad(-270) 
		else:
			pass

	animation_player.play("fishSwim")

#fish idle stuff
func fish_wander():
	while Global.fishleave == false:
		var point = wander_points[current_point]
		var rotationdeg = atan2(abs(point.global_position.y), abs(point.global_position.x))

		face_target(point.global_position)
		if point.global_position.y < global_position.y: 
			rotation.x = rotationdeg * -1 /4
		else: 
			rotation.x = rotationdeg /4

		var distance = global_position.distance_to(point.global_position)
		var duration = distance / swim_speed
		var wandertween = get_tree().create_tween()

		wandertween.tween_property(self, "global_position", point.global_position, duration)
		await wandertween.finished
		current_point += direction
		if current_point >= wander_points.size():
			current_point = wander_points.size() - 2
			direction = -1
		elif current_point < 0:
			current_point = 1
			direction = 1
		if current_point >= wander_points.size():
			current_point = 0

func fish_leave():
	print("running fish leave")
	rotation.z = deg_to_rad(0)
	var left_world = get_parent().screen_to_world(
		Vector2(0, get_parent().viewport_size.y / 2)
	)
	var right_world = get_parent().screen_to_world(
		Vector2(get_parent().viewport_size.x, get_parent().viewport_size.y / 2)
	)

	if get_parent().person_x * get_parent().viewport_size.x >= get_parent().viewport_size.x / 2:
		x_location = right_world.x + 2.0
		Global.spawnleft = true
	else:
		x_location = left_world.x - 2.0
		Global.spawnright = true
	
	var leaveTween = get_tree().create_tween()
	print("making tween")
	y_location = self.global_position.y
	leaveTween.tween_property(self, "global_position", Vector3(x_location, y_location, global_position.z),4)
	await leaveTween.finished
	print("finished tween")
	Global.fishgone = true
