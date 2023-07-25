extends SpotLight3D

@onready var Motorbike: VehicleBody3DSuzukiStreetBike = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#hide()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# this runs a lot better here in _process than in _input
	# https://stackoverflow.com/questions/69981662/godot-input-is-action-just-pressed-runs-twice
	if Motorbike.camera_moto.current:
		if Input.is_action_just_pressed("flashlight_toggle"):
			if visible:
				hide()
			else:
				show()
