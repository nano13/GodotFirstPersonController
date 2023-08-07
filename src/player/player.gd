class_name Player extends CharacterBody3D

@export_category("Player")

@onready var player_head: CollisionShape3D = get_node("%CShapeHead")
@onready var player_body: CollisionShape3D = get_node("%CShapeBody")
@onready var camera_fpc: CameraFPC = get_node("%CameraFPC")

@onready var state_machine: StateMachine = $StateMachine

@onready var state_no: State = State.new()
@onready var state_last: State
@onready var state_movement_land: State = get_node("%MovementLand")
@onready var state_movement_water: State = get_node("%MovementWater")
@onready var state_movement_ladder: State = get_node("%MovementLadder")

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

# if we transit from one ladder to another, we would like to stay in "ladder"-mode and not just fall off instead
var ladder_counter: int = 0

func _ready():
	state_movement_land.set_player(self)
	state_movement_water.set_player(self)
	state_movement_ladder.set_player(self)

func on_activate():
	state_machine.set_state(state_last)
	
	player_head.disabled = false
	player_body.disabled = false

func on_deactivate():
	state_last = state_machine.get_state()
	state_machine.set_state(state_no)
	
	player_head.disabled = true
	player_body.disabled = true

func on_land_entered():
	print("land entered")
	state_machine.set_state(state_movement_land)

func on_land_exited():
	print("land exited")
	pass

func on_ladder_entered(ladder: Ladder):
	print("ladder entered")
	ladder_counter += 1
	
	var velocities = state_machine.get_velocities()
	
	var state_previous = state_machine.get_state()
	state_machine.set_state(state_movement_ladder)
	if state_previous != state_movement_ladder:
		state_machine.set_state_previous(state_previous)
	
	state_machine.set_velocities(velocities)
	#state_movement_ladder.set_ladder(ladder)

func on_ladder_exited(ladder: Ladder):
	print("ladder exited")
	ladder_counter -= 1
	
	if ladder_counter <= 0:
		match state_machine.get_state_previous():
			state_movement_land:
				print("a: back to land")
				on_land_entered()
			state_movement_water:
				print("b: back to water")
				#on_water_entered()
				state_machine.set_state(state_movement_water)
			state_movement_ladder:
				print("c: still on ladder")
			_:
				print("wtf")

#func on_water_entered(water: Water):
func on_water_entered():
	print("water entered")
	
	match state_machine.get_state():
		state_movement_land, state_movement_water:
			print("_____ a")
			var velocities = state_machine.get_velocities()
			
			state_machine.set_state(state_movement_water)
			state_machine.set_velocities(velocities)
		
		state_movement_ladder:
			print("_____ b")
			state_machine.set_state_previous(state_movement_water)

#func on_water_exited(water: Water):
func on_water_exited():
	print("water exited")
	
	var state: State = state_machine.get_state()
	match state:
		state_movement_water:
			state.on_water_exited()
			
			var velocities = state_machine.get_velocities()
			
			state_machine.set_state(state_movement_land)
			state_machine.set_velocities(velocities)
		
		state_movement_ladder:
			state_machine.set_state_previous(state_movement_land)

func set_camera_rotation(rot: Vector3) -> void:
	camera_fpc.rotation = rot
