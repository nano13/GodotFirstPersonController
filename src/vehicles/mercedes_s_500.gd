class_name VehicleBody3DMercedesS500 extends VehicleBody3D

# https://www.b3dassets.com/2021/05/29/cars-3d-model-library/t

@export_category("MercedesS500")

@export_range(0, 100, 1) var brake_force: float = 100

var max_rpm = 600
var torque_min = 5000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_player_in_range: bool = false

var is_crashed: bool = false
var is_recovering: bool = false

var axis_left_right: float = 0

@onready var camera_car: Camera3D = get_node("%Camera3DMercedesS500")
@onready var camera_fpc: Camera3D = get_node("/root/World/Player/CShapeHead/CameraFPC")

@onready var player: CharacterBody3D = get_node("/root/World/Player")

@onready var wheel_front_left: VehicleWheel3D = get_node("%VehicleWheel3DMercedesS500FrontLeft")
@onready var wheel_front_right: VehicleWheel3D = get_node("%VehicleWheel3DMercedesS500FrontRight")
@onready var wheel_rear_left: VehicleWheel3D = get_node("%VehicleWheel3DMercedesS500RearLeft")
@onready var wheel_rear_right: VehicleWheel3D = get_node("%VehicleWheel3DMercedesS500RearRight")

@onready var exit_shape_left: CollisionShape3D = get_node("%CollisionShape3DExitLeft")
@onready var exit_shape_right: CollisionShape3D = get_node("%CollisionShape3DExitRight")

# only allow leaving the vehicle/spawning the player here if there is nothing in the way
var exit_shape_left_body_count: int = 0
var exit_shape_right_body_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_player_in_range:
		if Input.is_action_just_pressed("use"):
			enter_car()
	elif camera_car.current:
		if Input.is_action_just_pressed("use"):
			exit_car()

func _physics_process(delta):
	#freeze_if_not_used_and_crashed()
	
	#print("speed: ", linear_velocity.length())
	if camera_car.current:
		# for some reason Input.get_axis will not work properly if called from _integrate_forces
		# but we need to use it there, so we put it into a variable here
		var axis_left_right: float = Input.get_axis("vehicle_right", "vehicle_left")
		
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
		
		var acceleration: float = Input.get_axis("vehicle_accelerate", "vehicle_decelerate")
		var force: float = acceleration * torque_min * ( 1 - rpm / max_rpm)
		wheel_front_right.engine_force = force
		wheel_front_left.engine_force = force
		
		if Input.is_action_pressed("jump_default"):
			set_brake(brake_force)
		if Input.is_action_just_released("jump_default"):
			set_brake(0)
	else:
		# make sure the car does not keep going when the player exits while pressing "vehicle_forward"
		wheel_front_right.engine_force = 0
		wheel_front_left.engine_force = 0

func freeze_if_not_used_and_crashed():
	if linear_velocity.length() < 0.1:
		if (wheel_front_left.is_in_contact() and wheel_front_right.is_in_contact() and
		 wheel_rear_left.is_in_contact() and wheel_rear_right.is_in_contact() and
		 not camera_car.current):
			set_freeze_enabled(true)
		elif camera_car.current:
			set_freeze_enabled(false)

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		is_player_in_range = true
		player = body


func _on_area_3d_body_exited(body):
	if body.name == "Player":
		is_player_in_range = false

func enter_car():
	set_brake(0)
	
	if not is_crashed:
		camera_car.current = true
		player.on_deactivate()
	else:
		is_recovering = true
		
		var ray: CrosshairRay = player.get_node("CShapeHead/CameraFPC/CollisionRayCrosshair")
		ray.set_clicks_enabled(false)

func exit_car():
	var exited = false
	if exit_shape_left_body_count == 0:
		player.position = exit_shape_left.global_position
		exited = true
	elif exit_shape_right_body_count == 0:
		player.position = exit_shape_right.global_position
		exited = true
	
	if exited:
		# look roughly in the same direction (y-axis only) as before on the vehicle
		var rot: Vector3 = camera_car.global_rotation
		# if the car is tilted or fallen over on exit, we do not want to walk around after with a tilted head ...
		rot.x = 0
		rot.z = 0
		player.set_camera_rotation(rot)
		camera_car.current = false
		
		set_brake(brake_force)
		
		player.on_activate()


func _on_area_3d_exit_left_body_entered(body):
	if not body.name == "MercedesS500":
		exit_shape_left_body_count += 1

func _on_area_3d_exit_left_body_exited(body):
	exit_shape_left_body_count -= 1

func _on_area_3d_exit_right_body_entered(body):
	if not body.name == "MercedesS500":
		exit_shape_right_body_count += 1

func _on_area_3d_exit_right_body_exited(body):
	exit_shape_right_body_count -= 1
