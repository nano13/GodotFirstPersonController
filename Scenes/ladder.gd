extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body.name == "Player":
		body.ladder_array.append(self)
		if body.state_movement_current == body.MovementStates.LAND:
			body.state_movement_current = body.MovementStates.LADDER_LAND_ATTACHED
		elif body.state_movement_current == body.MovementStates.SWIM:
			body.state_movement_current = body.MovementStates.LADDER_WATER_ATTACHED

func _on_body_exited(body):
	if body.name == "Player":
		body.ladder_array.erase(self)
		if body.ladder_array.size() == 0:
			if body.state_movement_current == body.MovementStates.LADDER_LAND:
				body.state_movement_current = body.MovementStates.LAND
			elif body.state_movement_current == body.MovementStates.LADDER_WATER:
				body.state_movement_current = body.MovementStates.SWIM

