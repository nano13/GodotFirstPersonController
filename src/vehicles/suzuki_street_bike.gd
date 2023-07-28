class_name VehicleBody3DSuzukiStreetBike extends VehicleBody3D

# https://www.b3dassets.com/2022/09/03/blender-motorcycle-3d-model-library/
# https://www.youtube.com/watch?v=uKpO2X6wj4A

@export_category("Suzuki_Street_Bike")

@export_range(0, 100, 1) var brake_force: float = 20
@export_range(0, 10, 0.5) var wheel_distance: float = 1.5

var max_rpm = 600
var torque_min = 1600

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_player_in_range: bool = false

var is_crashed: bool = false
var is_recovering: bool = false

var axis_left_right: float = 0
var balance_left_right: float = 0

var steering_axis: Vector3 = Vector3(0.13, 1, 0).normalized()

@onready var camera_moto: Camera3D = get_node("%Camera3DSuzuki")
@onready var camera_fpc: Camera3D = get_node("%CShapeHead/CameraFPC")

@onready var player: CharacterBody3D = get_node("%Player")

@onready var player_head: CollisionShape3D = get_node("%CollisionShape3DHead")

@onready var wheel_front: VehicleWheel3D = get_node("%VehicleWheel3DFront")
@onready var wheel_rear: VehicleWheel3D = get_node("%VehicleWheel3DRear")
@onready var steering_fork: Node3D = get_node("%suzuki_motorbike_steering")
@onready var steering_wheel: VehicleWheel3D = get_node("%VehicleWheel3DSteering")

@onready var exit_shape_left: CollisionShape3D = get_node("%CollisionShape3DExitLeft")
@onready var exit_shape_right: CollisionShape3D = get_node("%CollisionShape3DExitRight")

# only allow leaving the vehicle/spawning the player here if there is nothing in the way
var exit_shape_left_body_count: int = 0
var exit_shape_right_body_count: int = 0

@onready var test: CSGCylinder3D = get_node("Node3D/CSGCylinder3Daiaaa")

func _ready():
	pass
	#mass = 300

func _integrate_forces(state):
	# only move the bike when we are "sitting on it"
	#if camera_moto.current:
	var theta:float = calculate_lean_angle_theta()
	
	lean_with_angular_velocity(theta)
	#lean_with_center_of_mass(theta)

func _physics_process(delta):
	# for some reason Input.get_axis will not work properly if called from _integrate_forces
	# but we need to use it there, so we put it into a variable here
	if camera_moto.current:
		axis_left_right = Input.get_axis("vehicle_right", "vehicle_left")
		balance_left_right = Input.get_axis("vehicle_balance_left", "vehicle_balance_right")
	
	if is_recovering:
		recover_motorbike()
	else:
		#freeze_if_not_used_and_crashed()
		#disable_player_head_if_no_player()
		
		calculate_acceleration(delta)
		
		if Input.is_action_just_pressed("use"):
			if camera_moto.current:
				exit_motorbike()
			elif is_player_in_range:
				enter_motorbike()

func freeze_if_not_used_and_crashed():
	if wheel_front.is_in_contact() and wheel_rear.is_in_contact() and not camera_moto.current and not is_crashed:
		# if moto lays too much on its side, we consider it crashed and don't freeze
		if abs(transform.basis.x.y) < 0.5:
			set_freeze_enabled(true)
	#elif sleeping:
	elif camera_moto.current:
		set_freeze_enabled(false)
		#linear_velocity = Vector3.ZERO
		#angular_velocity = Vector3.ZERO
		
	
	#print(linear_velocity)

func disable_player_head_if_no_player():
	if not camera_moto.current:
		player_head.disabled = true
	else:
		player_head.disabled = false

func calculate_lean_angle_theta() -> float:
	# to make it more realistic, the faster we go, the less we can turn the wheel
	var speed: float = linear_velocity.length()
	var steerdamp: float = clamp(speed/4, 2, 50)
	# use our axis_left_right input to turn the wheel
	var turn: float = axis_left_right / steerdamp
	# smooth out our steering movements
	steering = lerp(steering, turn, .1)
	
	# calculate turning radius
	var radius: float = ( wheel_distance / sin(steering) )
	
	# calculate the needed inclination angle theta
	var theta: float = atan(speed**2 / (gravity * radius))
	
	test.rotation.z = lerp(test.rotation.z, theta + PI/2, 1)
	
	return theta

func lean_with_angular_velocity(theta: float) -> void:
	# the steering angle is somewhat tilted. we need to try to counteradjust to that
	steering_fork.rotation = Vector3(0.4 + -(abs(steering)/15), steering, steering * 0.5)
	
	angular_velocity = calc_angular_velocity_(basis, basis.rotated(basis.z, theta))
	
	center_of_mass.x = rotation.z

func lean_with_center_of_mass(theta: float) -> void:
	pass

## a very basic approach
func lean_basic() -> void:
	# https://www.youtube.com/watch?v=uKpO2X6wj4A
	angular_velocity = lerp(angular_velocity, transform.basis.z * axis_left_right, 1)
	steering = lerp(steering, rotation.z/2, 1)

func calc_angular_velocity_(from_basis: Basis, to_basis: Basis) -> Vector3:
	#https://www.reddit.com/r/godot/comments/q1lawy/basis_and_angular_velocity_question/
	
	var q1: Quaternion = from_basis.get_rotation_quaternion()
	var q2: Quaternion = to_basis.get_rotation_quaternion()
	
	# Quaternion that transforms q1 into q2
	var qt: Quaternion = q2 * q1.inverse()
	
	var angle: float = qt.get_angle()
	var axis: Vector3 = qt.get_axis()
	
	return axis * angle

func calculate_acceleration(delta: float):
	if camera_moto.current:
		var rpm: float = clamp(wheel_rear.get_rpm(), -1 * max_rpm, 0)
		
		var acceleration: float = Input.get_axis("vehicle_accelerate", "vehicle_decelerate")
		wheel_rear.engine_force = acceleration * torque_min * ( 1 - rpm / max_rpm)
		
		if Input.is_action_pressed("jump_default"):
			set_brake(brake_force)
		if Input.is_action_just_released("jump_default"):
			set_brake(0)
	else:
		wheel_rear.engine_force = 0

func _process(delta):
	#if is_recovering:
	#	recover_motorbike()
	pass

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		is_player_in_range = true
		player = body

func _on_area_3d_body_exited(body):
	if body.name == "Player":
		is_player_in_range = false

func enter_motorbike():
	set_brake(0)
	
	if not is_crashed:
		camera_moto.current = true
		player.on_deactivate()
	else:
		is_recovering = true
		
		var ray: CrosshairRay = player.get_node("CShapeHead/CameraFPC/CollisionRayCrosshair")
		ray.set_clicks_enabled(false)

func exit_motorbike():
	var exited: bool = false
	if exit_shape_left_body_count == 0:
		player.position = exit_shape_left.global_position
		exited = true
	elif exit_shape_right_body_count == 0:
		player.position = exit_shape_right.global_position
		exited = true
	
	if exited:
		# look roughly in the same direction (y-axis only) as before on the vehicle
		var rot: Vector3 = camera_moto.global_rotation
		# if the bike is tilted or fallen over on exit, we do not want to walk around after with a tilted head ...
		rot.x = 0
		rot.z = 0
		player.set_camera_rotation(rot)
		camera_moto.current = false
		
		set_brake(brake_force)
		
		player.on_activate()

func recover_motorbike():
	var ray: CrosshairRay = player.get_node("CShapeHead/CameraFPC/CollisionRayCrosshair")
	
	if ray.is_colliding():
		var collision_point := ray.get_collision_point()
		
		set_freeze_enabled(true)
		
		transform.basis.x = Vector3(1, 0, 0)
		transform.basis.y = Vector3(0, 1, 0)
		transform.basis.z = Vector3(0, 0, 1)
		
		if collision_point.distance_to(player.position) > 1.5:
			position = Vector3(collision_point.x, collision_point.y + .5, collision_point.z)
		else:
			#print("aaaaa")
			pass
		
		if Input.is_action_just_pressed("fire_primary"):
			is_crashed = false
			is_recovering = false
			
			set_freeze_enabled(false)
			
			ray.set_clicks_enabled(true)
		

func _on_area_3d_crash_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name != "Player" and body.name != "Motorbike":
		print("crashed by polygon: ", body)
		#is_crashed = true


func _on_area_3d_exit_left_body_entered(body):
	if not body.name == "Suzuki_Street_Bike":
		exit_shape_left_body_count += 1

func _on_area_3d_exit_left_body_exited(body):
	exit_shape_left_body_count -= 1

func _on_area_3d_exit_right_body_entered(body):
	if not body.name == "Suzuki_Street_Bike":
		exit_shape_right_body_count += 1

func _on_area_3d_exit_right_body_exited(body):
	exit_shape_right_body_count -= 1
