extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_global_rotation_degrees(Vector3(1, 1, 1))
	global_scale(Vector3(0.015, 0.015, 0.015))
