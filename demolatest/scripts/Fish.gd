extends Node3D

@onready var wander_points = get_parent().get_node("WanderPoints").get_children()
@onready var animation_player = $AnimationPlayer

@export var wander_direction : Node3D
@export var swim_speed := 2.0
@export var pitch_factor := 0.5
@export var max_pitch_deg := 45.0

var x_location: float
var y_location: float
var current_point := 0
var direction := 1
var facing := 1  # 1 = facing +X, -1 = facing -X

var current_target: Vector3
var pitch_active := false  # only recompute rotation.x while this is true

func _ready():
	animation_player.play("fishSwim_001")
	var screen_x = get_parent().person_x * get_parent().viewport_size.x
	var world_pos = get_parent().screen_to_world(
		Vector2(screen_x, get_parent().viewport_size.y / 2)
	)
	x_location = world_pos.x
	y_location = get_parent().fish_y_spawn

	var enter_tween = get_tree().create_tween()
	enter_tween.tween_property(self, "position", Vector3(x_location, y_location, 0), 4.0)
	await enter_tween.finished
	fish_wander()

func _process(_delta):
	if Global.fishleave:
		Global.fishleave = false
		fish_leave()
	if Global.spawnleft:
		Global.spawnleft = false
		set_facing(1)
	if Global.spawnright:
		Global.spawnright = false
		set_facing(-1)
	if Global.spinfish:
		Global.spinfish = false
		fish_spin()

	# Continuously reasserts pitch every frame so it can't get stuck/overridden
	# by an animation track, and stays accurate as the fish physically moves.
	if pitch_active:
		_update_pitch(current_target)

func _update_pitch(target: Vector3) -> void:
	var to_target = target - global_position
	var horizontal_dist = abs(to_target.x)
	if horizontal_dist < 0.001 and abs(to_target.y) < 0.001:
		return  # basically at the target, don't fight for a direction
	var pitch = atan2(to_target.y, horizontal_dist) * pitch_factor
	rotation.x = clamp(pitch, deg_to_rad(-max_pitch_deg), deg_to_rad(max_pitch_deg))

func set_facing(new_facing: int) -> void:
	facing = new_facing
	rotation.y = deg_to_rad(-90 if facing == 1 else 90)

## Handles yaw / turn-animation only now. Pitch is handled continuously in _process.
func face_target(target: Vector3) -> void:
	current_target = target
	var to_target = target - global_position
	var new_facing = 1 if to_target.x >= 0.0 else -1
	

	#if new_facing == 1:
		#self.scale = Vector3(-1,-1,-1)
	#if new_facing == -1:
		#self.scale = Vector3(1,1,1)

	if new_facing != facing:
		animation_player.play("FishTurnR" if new_facing == -1 else "FishTurnL")
		print(animation_player.current_animation)
		await animation_player.animation_finished
		set_facing(new_facing)
		animation_player.play("fishSwim_001")

func fish_wander():
	pitch_active = true
	while not Global.fishleave and not Global.spinfish:
		var point = wander_points[current_point]
		await face_target(point.global_position)

		var distance = global_position.distance_to(point.global_position)
		var duration = distance / swim_speed
		var wander_tween = get_tree().create_tween()
		wander_tween.tween_property(self, "global_position", point.global_position, duration)
		await wander_tween.finished

		current_point += direction
		if current_point >= wander_points.size():
			current_point = wander_points.size() - 2
			direction = -1
		elif current_point < 0:
			current_point = 1
			direction = 1
	pitch_active = false

func fish_leave():
	pitch_active = false
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

	var leave_tween = get_tree().create_tween()
	y_location = self.global_position.y
	leave_tween.tween_property(self, "global_position", Vector3(x_location, y_location, global_position.z), 4)
	await leave_tween.finished
	Global.fishgone = true

func fish_spin():
	animation_player.play("FishSpin")
	await animation_player.animation_finished
	
	##trying to reset pos 
	#pitch_active = false
	#var pre_spin_transform := transform  # cache position + rotation + scale
#
	#animation_player.play("FishSpin")
	#await animation_player.animation_finished
#
	#transform = pre_spin_transform  # snap back to exact pre-spin state
	#pitch_active = true
