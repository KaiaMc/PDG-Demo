extends CharacterBody2D
@onready var fih = $"."
@onready var animation_player = $AnimationPlayer
@onready var wander_points = get_parent().get_node("WanderPoints").get_children()
@export var wander_direction : Node2D
@export var swim_speed := 100.0

var x_location
var y_location
var current_point := 0
var direction := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("hello")
	x_location = get_parent().person_x * get_parent().viewport_size.x
	y_location = get_parent().fish_y_spawn
	var enterTween = get_tree().create_tween()
	enterTween.tween_property(self, "position", Vector2(x_location, y_location), 3.0)
	await enterTween.finished
	fish_wander()

#fish idle stuff
func fish_wander():
	while true:
		var point = wander_points[current_point]
		if point.global_position.x < global_position.x:
			scale.x = -0.3
		else:
			scale.x = 0.3
		var distance = global_position.distance_to(point.global_position)
		var duration = distance / swim_speed
		var wandertween = get_tree().create_tween()
		wandertween.tween_property(self, "global_position", point.global_position, duration)

		if Testglobal.fishleave == true:
			if x_location * get_parent().viewport_size.x <= 960:
				x_location = 3000 #off screen to RIGHT
			else:
				x_location = -100 #off screen to LEFT
				
			wandertween.kill()
			var leaveTween = get_tree().create_tween()
			y_location = self.global_position.y
			leaveTween.tween_property(self, "global_position", Vector2(x_location, y_location), 5.0)
			await leaveTween.finished
			Testglobal.fishgone = true
			Testglobal.fishleave = false
			return

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
