class_name PlayerFlashlight extends SpotLight3D

@onready var player: Player = get_parent().get_parent().get_parent()
@onready var player_fpc: CameraFPC = get_node("%CShapeHead/CameraFPC")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# this runs a lot better here in _process than in _input
	# https://stackoverflow.com/questions/69981662/godot-input-is-action-just-pressed-runs-twice
	if Input.is_action_just_pressed("flashlight_toggle"):
		if player_fpc.current:
			if visible:
				hide()
			else:
				show()
	
	if not player_fpc.current:
		hide()
