class_name CameraFPC extends Camera3D

@export_range(0.1, 30, 0.05, "or_greater") var sens_mouse: float = 14
@export_range(0.1, 30, 0.05, "or_greater") var sens_gamepad: float = 5


var look_dir: Vector2 # Input direction for look/aim

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.0001
		_rotate_camera()

func _input(event: InputEvent) -> void:
	pass

func _physics_process(delta: float) -> void:
	_handle_joypad_camera_rotation(delta)

func _process(delta: float):
	pass

func _rotate_camera(sens_mod: float = 1.0) -> void:
	rotation.y -= look_dir.x * sens_mouse * sens_mod
	rotation.x = clamp(rotation.x - look_dir.y * sens_mouse * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		
		rotation.y -= look_dir.x * sens_gamepad * sens_mod
		rotation.x = clamp(rotation.x - look_dir.y * sens_gamepad * sens_mod, -1.5, 1.5)
		
		look_dir = Vector2.ZERO