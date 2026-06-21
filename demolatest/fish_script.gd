extends Sprite2D
@onready var fih = $"."
@onready var animation_player = $AnimationPlayer

var x_location
var y_location

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("hello")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
