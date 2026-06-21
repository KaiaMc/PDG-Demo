extends PathFollow2D

var speed = 0.01

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress_ratio += delta * speed
