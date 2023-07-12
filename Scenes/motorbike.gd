extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_active: bool = false
var is_player_inside: bool = false

@onready var camera_moto: Camera3D = get_node("%Camera3DMotorbike")
@onready var camera_fpc: Camera3D = get_node("%CameraFPC")
@onready var player: CharacterBody3D = get_node("%Player")

func _ready():
	print("ready")
	

func _physics_process(delta):
	if Input.is_action_just_pressed("use"):
		if is_player_inside:
			print("aaaaaaaaaaaaaaaaaaaaaaaaaaaau")
			enter_motorbike()
		else:
			exit_motorbike()
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should 50replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if is_active:
		move_and_slide()

func _process(delta):
	pass

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		is_player_inside = true

func _on_area_3d_body_exited(body):
	if body.name == "Player":
		is_player_inside = false

func enter_motorbike():
	camera_moto.current = true
	is_active = true

func exit_motorbike():
	#camera_fpc.current = true
	camera_moto.current = false
	is_active = false
