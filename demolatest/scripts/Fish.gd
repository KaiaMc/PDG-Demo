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
	animation_player.play("Armature")
	var screen_x = get_parent().person_x * get_parent().viewport_size.x
	var world_pos = get_parent().screen_to_world(
		Vector2(screen_x, get_parent().viewport_size.y / 2)
	)
	x_location = world_pos.x
	y_location = get_parent().fish_y_spawn
	var enterTween = get_tree().create_tween()
	enterTween.tween_property(self, "position", Vector3(x_location, y_location, 0), 3.0)
	await enterTween.finished
	fish_wander()

func _process(delta):
	if Testglobal.fishleave == true:
		fish_leave()
		Testglobal.fishleave = false

func face_target(target: Vector3):
	var move_direction = target - global_position

	if move_direction.x < 0:
		rotation.x = -atan2(move_direction.y, abs(move_direction.x))
	else:
		rotation.x = atan2(move_direction.y, abs(move_direction.x))

#fish idle stuff
func fish_wander():
	while Testglobal.fishleave == false:
		var point = wander_points[current_point]
		face_target(point.global_position)
		if point.global_position.x < global_position.x:
			rotation.y = deg_to_rad(270)
		else:
			rotation.y = deg_to_rad(90)
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
	var left_world = get_parent().screen_to_world(
		Vector2(0, get_parent().viewport_size.y / 2)
	)
	var right_world = get_parent().screen_to_world(
		Vector2(get_parent().viewport_size.x, get_parent().viewport_size.y / 2)
	)

	if get_parent().person_x * get_parent().viewport_size.x >= get_parent().viewport_size.x / 2:
		x_location = right_world.x + 2.0
	else:
		x_location = left_world.x - 2.0
	
	var leaveTween = get_tree().create_tween()
	print("making tween")
	y_location = self.global_position.y
	leaveTween.tween_property(
		self,
		"global_position",
		Vector3(x_location, y_location, global_position.z),
		4
	)
	await leaveTween.finished
	print("finished tween")
	Testglobal.fishgone = true
