class_name Motorbike extends VehicleBody3D

# https://www.b3dassets.com/2022/09/03/blender-motorcycle-3d-model-library/

var max_rpm = 600
var torque_min = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_active: bool = false
var is_player_in_range: bool = false

var is_crashed: bool = false

@onready var camera_moto: Camera3D = get_node("%Camera3DMotorbike")
@onready var camera_fpc: Camera3D = get_node("%CameraFPC")

@onready var player: CharacterBody3D = get_node("%Player")

@onready var player_head: CollisionShape3D = get_node("%CollisionShape3DHead")

@onready var wheel_front: VehicleWheel3D = get_node("%VehicleWheel3DFront")
@onready var wheel_rear: VehicleWheel3D = get_node("%VehicleWheel3DRear")

func _ready():
	print("ready")
	
	#set_can_sleep(true)
	
	# aufbäumen, kann umfallen
	#axis_lock_angular_x = true
	
	# kann nicht lenken
	#axis_lock_angular_y = true
	
	# kein aufbäumen, kann umfallen
	#axis_lock_angular_z = true

func _integrate_forces(state):
	if is_active:
		calculate_lean()

func _physics_process(delta):
	sleep_if_not_used_and_crashed()
	disable_player_head_if_no_player()
	
	#calculate_lean()
	calculate_steering(delta)
	
	if Input.is_action_just_pressed("use"):
		if is_active:
			exit_motorbike()
		elif is_player_in_range:
			enter_motorbike()
	
	

func sleep_if_not_used_and_crashed():
	if wheel_front.is_in_contact() and wheel_rear.is_in_contact() and not is_active and not is_crashed:
		set_freeze_enabled(true)
	#elif sleeping:
	elif is_active:
		set_freeze_enabled(false)
		#linear_velocity = Vector3.ZERO
		#angular_velocity = Vector3.ZERO
		
	
	#print(linear_velocity)

func disable_player_head_if_no_player():
	if not is_active:
		player_head.disabled = true
	else:
		player_head.disabled = false

func calculate_lean():
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
	if is_active:
		var rpm: float = clamp(wheel_rear.get_rpm(), -1 * max_rpm, 0)
		#print("rpm: ", rpm)
		
		# we want to get the steering softer the faster we go
		#var steer_mult: float = (1 / 1.5)**(abs(rpm)/40) + .05 #* 0.4
		#var steer_mult: float = (1 / 1.5)**(abs(rpm)/400) + .05 #* 0.4
		#print("mult: ", steer_mult)
		steering = lerp(steering, Input.get_axis("move_right", "move_left") * 0.4, 5 * delta)
		#steering = lerp(steering, Input.get_axis("move_right", "move_left") * steer_mult, 2 * delta)
		#print("steer: ", steering)
		
		var acceleration: float = Input.get_axis("move_forward", "move_backward")
		wheel_rear.engine_force = acceleration * torque_min * ( 1 - rpm / max_rpm)
		
		if Input.is_action_pressed("jump_default"):
			set_brake(2)
		if Input.is_action_just_released("jump_default"):
			set_brake(0)

func _process(delta):
	pass

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		is_player_in_range = true
		player = body

func _on_area_3d_body_exited(body):
	if body.name == "Player":
		is_player_in_range = false

func enter_motorbike():
	camera_moto.current = true
	is_active = true
	player.on_deactivate()

func exit_motorbike():
	camera_moto.current = false
	is_active = false
	player.on_activate()
