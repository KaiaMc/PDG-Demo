extends Sprite2D
@onready var fih = $"."
@onready var animation_player = $AnimationPlayer

var x_location
var y_location

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
	animation_player.play("swim")
	#hitboxes mult with neg 1 to turn direction
