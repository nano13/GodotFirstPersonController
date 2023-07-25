extends VehicleBody3D

# https://www.b3dassets.com/2021/05/29/cars-3d-model-library/

var max_rpm = 600
var torque_min = 5000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_player_in_range: bool = false

var is_crashed: bool = false
var is_recovering: bool = false

var axis_left_right: float = 0

@onready var camera_car: Camera3D = get_node("%Camera3DMercedesS500")
@onready var camera_fpc: Camera3D = get_node("%CameraFPC")

@onready var player: CharacterBody3D = get_node("%Player")

#@onready var player_head: CollisionShape3D = get_node("%CollisionShape3DHead")

@onready var wheel_front_left: VehicleWheel3D = get_node("%VehicleWheel3DMercedesS500FrontLeft")
@onready var wheel_front_right: VehicleWheel3D = get_node("%VehicleWheel3DMercedesS500FrontRight")
#@onready var wheel_rear: VehicleWheel3D = get_node("%VehicleWheel3DRear")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("use"):
		if camera_car.current:
			exit_car()
		elif is_player_in_range:
			enter_car()

func _physics_process(delta):
	# for some reason Input.get_axis will not work properly if called from _integrate_forces
	# but we need to use it there, so we put it into a variable here
	
	var axis_left_right: float = Input.get_axis("move_right", "move_left")
	
	var speed: float = linear_velocity.length()
	# to make it more realistic, the faster we go, the less we can turn the wheel
	var steerdamp: float = clamp(speed/1.5, 2, 50)
	var turn: float = axis_left_right / steerdamp
	# smooth out our steering movements
	steering = lerp(steering, turn, .1)
	
	calculate_acceleration(delta)

func calculate_acceleration(delta: float):
	if camera_car.current:
		var rpm: float = clamp(wheel_front_right.get_rpm(), -1 * max_rpm, 0)
		
		#steering = lerp(steering, Input.get_axis("vehicle_right", "vehicle_left") * 0.4, 5 * delta)
		#####steering = lerp(steering, Input.get_axis("move_right", "move_left") * 0.4, 5 * delta)
		
		var acceleration: float = Input.get_axis("vehicle_accelerate", "vehicle_decelerate")
		var force: float = acceleration * torque_min * ( 1 - rpm / max_rpm)
		wheel_front_right.engine_force = force
		wheel_front_left.engine_force = force
		
		if Input.is_action_pressed("jump_default"):
			set_brake(200)
		if Input.is_action_just_released("jump_default"):
			set_brake(0)

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		is_player_in_range = true
		player = body


func _on_area_3d_body_exited(body):
	if body.name == "Player":
		is_player_in_range = false

func enter_car():
	if not is_crashed:
		camera_car.current = true
		player.on_deactivate()
	else:
		is_recovering = true
		
		var ray: CrosshairRay = player.get_node("CShapeHead/CameraFPC/CollisionRayCrosshair")
		ray.set_clicks_enabled(false)

func exit_car():
	camera_car.current = false
	player.on_activate()
