class_name Motorbike extends VehicleBody3D

# https://www.b3dassets.com/2022/09/03/blender-motorcycle-3d-model-library/

var max_rpm = 600
var torque_min = 100

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

func _ready():
	pass
	
	#set_can_sleep(true)
	
	# aufbäumen, kann umfallen
	#axis_lock_angular_x = true
	
	# kann nicht lenken
	#axis_lock_angular_y = true
	
	# kein aufbäumen, kann umfallen
	#axis_lock_angular_z = true

func _integrate_forces(state):
	if camera_moto.current:
		calculate_lean()
		pass

func _physics_process(delta):
	axis_left_right = Input.get_axis("vehicle_right", "vehicle_left")
	
	if is_recovering:
		recover_motorbike()
	else:
		freeze_if_not_used_and_crashed()
		#disable_player_head_if_no_player()
		
		#calculate_lean()
		calculate_steering(delta)
		
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
	#print(axis_left_right, angular_velocity.z)
	angular_velocity = Vector3(angular_velocity.x, angular_velocity.y, axis_left_right)
	"""
	# 0 if upgright, 1 or -1 if laying on the ground on its side
	if transform.basis.x.y > 0.1:
		#print("falling left")
		#print(angular_velocity)
		#angular_velocity = Vector3(angular_velocity.x, angular_velocity.y, -angular_velocity.z)
		angular_velocity = Vector3(angular_velocity.x, angular_velocity.y, -angular_velocity.z * axis_left_right * 1)
	elif transform.basis.x.y < -0.1:
		#print("falling right")
		#angular_velocity = Vector3(angular_velocity.x, angular_velocity.y, -angular_velocity.z)
		angular_velocity = Vector3(angular_velocity.x, angular_velocity.y, -angular_velocity.z * axis_left_right * 1)
	"""

func calculate_lean_old():
	#var basis_z: Vector3 = global_transform.basis.y
	#print(basis_z)
	#global_transform.basis.y = Vector3(basis_z.x, 1, basis_z.z)
	
	var bas_x: Vector3 = global_transform.basis.x
	#print(bas_x)
	#global_transform.basis.x = Vector3(bas_x.x, 0, bas_x.z)
	
	var bas_y: Vector3 = global_transform.basis.y
	#print(bas_y.y)
	
	#var bas_z: Vector3 = global_transform.basis.z
	
	# hold moto from falling sideways, unless it has flipped over forwards before
	if bas_y.y > 0 and not is_crashed:
		#var up = move_toward(0, bas_x.y, delta)
		#global_transform.basis.x = Vector3(bas_x.x, 0, bas_x.z)
		#print(bas_x.y)
		
		var steer: float = Input.get_axis("move_right", "move_left") * 0.4
		
		#print(bas_x.y)
		#print(transform.basis.x)
		
		if bas_x.y > 0.001 or bas_x.y < -0.001:
			#print("falling left")
			#angular_velocity = Vector3(angular_velocity.x, angular_velocity.y, -angular_velocity.z)
			#angular_velocity = lerp(angular_velocity, Vector3(angular_velocity.x, angular_velocity.y, -bas_x.y), .8)
			#angular_velocity = lerp(angular_velocity, -transform.basis.z * -0.0, 1)
			#print(transform.basis.z)
			pass
		"""
		if bas_x.y < -0.001:
			print("falling right")
			#angular_velocity = Vector3(angular_velocity.x, angular_velocity.y, -angular_velocity.z)
			#angular_velocity = lerp(angular_velocity, Vector3(angular_velocity.x, angular_velocity.y, -bas_x.y), .8)
			angular_velocity = lerp(angular_velocity, -transform.basis.z, 1)
		"""
		
		#print(angular_velocity.z)
		#print("a ", angular_velocity)
		#angular_velocity = Vector3(angular_velocity.x, angular_velocity.y, 0)
		#angular_velocity = Vector3.ZERO
		#angular_velocity = angular_velocity
		#angular_velocity = lerp(angular_velocity, -transform.basis.z, 0.1)
		#angular_velocity = lerp(angular_velocity, Vector3(angular_velocity.x, angular_velocity.y, 0), 0.1)
		#linear_velocity = Vector3.UP
		#angular_velocity = Vector3(0, 0, 0)
	else:
		is_crashed = true
	
	#print("a ", angular_velocity)

func calculate_steering(delta: float):
	if camera_moto.current:
		var rpm: float = clamp(wheel_rear.get_rpm(), -1 * max_rpm, 0)
		#print("rpm: ", rpm)
		
		# we want to get the steering softer the faster we go
		#var steer_mult: float = (1 / 1.5)**(abs(rpm)/40) + .05 #* 0.4
		#var steer_mult: float = (1 / 1.5)**(abs(rpm)/400) + .05 #* 0.4
		#print("mult: ", steer_mult)
		
		#steering = lerp(steering, Input.get_axis("vehicle_right", "vehicle_left") * 0.4, 5 * delta)
		
		#steering = lerp(steering, Input.get_axis("move_right", "move_left") * steer_mult, 2 * delta)
		#print("steer: ", steering)
		
		var acceleration: float = Input.get_axis("vehicle_accelerate", "vehicle_decelerate")
		wheel_rear.engine_force = acceleration * torque_min * ( 1 - rpm / max_rpm)
		
		if Input.is_action_pressed("jump_default"):
			set_brake(2)
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
		print(body, ": crashed by polygon")
		is_crashed = true
