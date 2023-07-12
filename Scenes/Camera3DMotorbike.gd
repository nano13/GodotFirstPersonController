extends Camera3D

@export_range(0.1, 30, 0.05, "or_greater") var camera_sens: float = 14

var look_dir: Vector2 # Input direction for look/aim


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.0001
		_rotate_camera()

func _rotate_camera(sens_mod: float = 1.0) -> void:
	rotation.y -= look_dir.x * camera_sens * sens_mod
	rotation.x = clamp(rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)
