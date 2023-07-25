class_name Motorbike extends VehicleBody3D

# https://www.b3dassets.com/2022/09/03/blender-motorcycle-3d-model-library/
# https://www.youtube.com/watch?v=uKpO2X6wj4A

var max_rpm = 600
var torque_min = 1600

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_player_in_range: bool = false

var is_crashed: bool = false
var is_recovering: bool = false

var axis_left_right: float = 0

@onready var camera_moto: Camera3D = get_node("%Camera3DSuzuki")
@onready var camera_fpc: Camera3D = get_node("%CameraFPC")

@onready var player: CharacterBody3D = get_node("%Player")

@onready var player_head: CollisionShape3D = get_node("%CollisionShape3DHead")

@onready var wheel_front: VehicleWheel3D = get_node("%VehicleWheel3DFront")
@onready var wheel_rear: VehicleWheel3D = get_node("%VehicleWheel3DRear")

@onready var test: CSGCylinder3D = get_node("Node3D/CSGCylinder3Daiaaa")

func _ready():
	pass
	#mass = 300

func _integrate_forces(state):
	# only move the bike when we are "sitting on it"
	if camera_moto.current:
		calculate_lean()
		pass

func _physics_process(delta):
	# for some reason Input.get_axis will not work properly if called from _integrate_forces
	# but we need to use it there, so we put it into a variable here
	axis_left_right = Input.get_axis("move_right", "move_left")
	
	if is_recovering:
		recover_motorbike()
	else:
		freeze_if_not_used_and_crashed()
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

func calculate_lean():
	#print()
	# use our axis_left_right input to turn the wheel
	var speed: float = linear_velocity.length()
	# to make it more realistic, the faster we go, the less we can turn the wheel
	var steerdamp: float = clamp(speed/4, 2, 50)
	var turn: float = axis_left_right / steerdamp
	# smooth out our steering movements
	var steer: float = lerp(steering, turn, .1)
	
	# calculate turning radius
	# 1.5 is the distance between the wheels in meter
	# steering is the angle of the wheel in radians
	var radius: float = ( 1.5 / sin(steer) )
	
	# calculate the needed inclination angle theta
	var theta: float = atan(speed**2 / (gravity * radius))
	
	test.rotation.z = lerp(test.rotation.z, theta + PI/2, 1)
	
	# https://www.youtube.com/watch?v=uKpO2X6wj4A
	#angular_velocity = lerp(angular_velocity, transform.basis.z * axis_left_right, 1)
	#steering = lerp(steering, rotation.z/2, 1)
	steering = steer
	
	#print("angular_velocity: ", angular_velocity)
	
	# https://docs.godotengine.org/en/stable/tutorials/physics/rigid_body.html
	# as our motorbike is a VehicleBody3D derived from RigidBody3D,
	# we can not just manipulate e.g. rotation.z to apply the angle theta,
	# but we need to use angular_velocity instead with some extra calculations
	#rotation.z = theta #axis_left_right
	#angular_velocity = lerp(angular_velocity, Vector3(angular_velocity.x, angular_velocity.y, theta), 1)
	#angular_velocity = lerp(angular_velocity, Vector3(angular_velocity.x, angular_velocity.y, theta), 1)
	#angular_velocity = calc_angular_velocity_between_basises(basis, Quaternion(basis.rotated(Vector3(0, 0, 1), theta)))
	#angular_velocity = lerp(rotation, rotation.rotated(Vector3(0, 0, 1), 0), 1)
	#angular_velocity = lerp(angular_velocity, transform.basis.z * theta, 1)
	#angular_velocity = lerp(angular_velocity, Vector3(rotation.x, rotation.y, axis_left_right), 1)
	#angular_velocity.z = lerp_angle(rotation.z, theta, 1)
	#rotate_z()
	
	# chatgpt. almost works, crashes after a short while
	#var rotation_quat: Quaternion = Quaternion(Vector3(0, 0, 1), theta)
	#angular_velocity = Vector3.ZERO
	#rotation.z = theta
	
	var target_quat: Quaternion = basis.get_rotation_quaternion()
	target_quat.z = theta
	#var axis = Vector3(0, 0.5, 0.5).normalized()
	var axis: Vector3 = rotation
	#axis.y = 0
	print(axis)
	var base: Basis = basis
	#base.y = Vector3.ZERO
	print(base.orthonormalized())
	var vel: Vector3 = calc_angular_velocity(base.orthonormalized(), Quaternion(axis.normalized(), theta))
	#var vel: Vector3 = calc_angular_velocity(basis, target_quat)
	#print(basis.get_rotation_quaternion())
	angular_velocity = vel
	#angular_velocity = Vector3(angular_velocity.x, angular_velocity.y, vel.z)
	
	#var vel: Vector3 = calc_angular_velocity(basis, Quaternion(Vector3(0, 0, 1), theta))
	#angular_velocity = vel
	
	# this seems to run in some kind of a gimbal lock if turned around 90 degrees
	#axis_lock_angular_z = false
	#angular_velocity = Vector3.ZERO
	#rotation.z = theta
	
	#angular_velocity = calc_angular_velocity_between_basises(Quaternion(Vector3(0, 0, 1), rotation.z), Quaternion(Vector3(0, 0, 1), theta))
	
	#angular_velocity = Vector3(angular_velocity.x, angular_velocity.y, vel.z)
	#angular_velocity = lerp(angular_velocity, Vector3(angular_velocity.x, angular_velocity.y, theta), 1)
	
	
	#print("speed: ", speed)
	#print("transform.basis.z: ", transform.basis.z)
	#print("theta: ", theta)
	#print("rotation: ", rotation)
	#print("angular_velocity: ", angular_velocity)
	
	#print(rotation.z/2, " : ", linear_velocity.length()/50)

func calc_angular_velocity_(from_basis: Basis, to_basis: Basis) -> Vector3:
	var q1 := from_basis.get_rotation_quaternion()
	var q2 := to_basis.get_rotation_quaternion()
	
	var qt := q2 * q1.inverse()
	
	var angle := qt.get_angle()
	var axis := qt.get_axis()
	
	return axis * angle

func calc_angular_velocity(from_basis: Basis, to_basis: Basis) -> Vector3:
	#https://www.reddit.com/r/godot/comments/q1lawy/basis_and_angular_velocity_question/
	
	var q1: Quaternion = from_basis.get_rotation_quaternion()
	var q2: Quaternion = to_basis.get_rotation_quaternion()
	
	# Quaternion that transforms q1 into q2
	var qt = q2 * q1.inverse()
	
	# Angle from quaternion
	var angle = 2 * acos(qt.w)
	
	# Prevent divide by zero
	if angle < 0.0001:
		return Vector3.ZERO
	
	# Axis from quaternion
	var axis = Vector3(qt.x, qt.y, qt.z) / sqrt(1-qt.w*qt.w)
	
	return axis * angle

func calculate_acceleration(delta: float):
	if camera_moto.current:
		var rpm: float = clamp(wheel_rear.get_rpm(), -1 * max_rpm, 0)
		
		#steering = lerp(steering, Input.get_axis("vehicle_right", "vehicle_left") * 0.4, 5 * delta)
		#####steering = lerp(steering, Input.get_axis("move_right", "move_left") * 0.4, 5 * delta)
		
		var acceleration: float = Input.get_axis("vehicle_accelerate", "vehicle_decelerate")
		wheel_rear.engine_force = acceleration * torque_min * ( 1 - rpm / max_rpm)
		
		if Input.is_action_pressed("jump_default"):
			set_brake(20)
		if Input.is_action_just_released("jump_default"):
			set_brake(0)

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
	if not is_crashed:
		camera_moto.current = true
		player.on_deactivate()
	else:
		is_recovering = true
		
		var ray: CrosshairRay = player.get_node("CShapeHead/CameraFPC/CollisionRayCrosshair")
		ray.set_clicks_enabled(false)

func exit_motorbike():
	camera_moto.current = false
	player.on_activate()

func recover_motorbike():
	var ray: CrosshairRay = player.get_node("CShapeHead/CameraFPC/CollisionRayCrosshair")
	
	if ray.is_colliding():
		var collision_point := ray.get_collision_point()
		
		set_freeze_enabled(true)
		
		transform.basis.x.x = 1
		transform.basis.x.y = 0
		transform.basis.x.z = 0
		
		transform.basis.y.x = 0
		transform.basis.y.y = 1
		transform.basis.y.z = 0
		
		transform.basis.z.x = 0
		transform.basis.z.y = 0
		transform.basis.z.z = 1
		
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
