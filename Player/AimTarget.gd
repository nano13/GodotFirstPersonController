extends Sprite3D

var aim_target_show: bool = false

@onready var ray: RayCast3D = get_node("%CollisionRayCrosshair")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# place AimTarget at the collision point facing towards the normal of the given surface
	if ray.is_colliding() and aim_target_show:
		var collision_point := ray.get_collision_point()
		var collision_normal := ray.get_collision_normal()
		global_transform.origin = collision_point + collision_normal * 0.01 # 0.01 is the distance of the sprite above the target
		
		look_at_safe(collision_point, collision_normal)
		
		show()
	
	else:
		hide()
	
	# toggle visibility with fire_secondary
	if Input.is_action_just_pressed("fire_secondary"):
		if aim_target_show:
			aim_target_show = false
		else:
			aim_target_show = true

func look_at_safe(point: Vector3, normal: Vector3) -> void:
	# https://godotforums.org/d/30764-lookat-fails-sometimes
	# we need to check for a valid up-vector to avoid gimbal locks
	# maybe there is a way to do this better and easier using quaternions/Vector4 instead ...
	var up: Vector3 = global_transform.basis.y.normalized()
	#if (abs(collision_normal.x) > 0.99):
	#	print("xxxx")
	if (abs(normal.y) > 0.99):
		up = Vector3.RIGHT
	if (abs(normal.z) > 0.99):
		up = Vector3.UP
	
	# detect if normal and abs are the same
	var normal_abs: Vector3 = abs(normal)
	var up_abs: Vector3 = abs(up)
	if (round(normal_abs.x * 1000) == round(up_abs.x * 1000) and
	 round(normal_abs.y * 1000) == round(up_abs.y * 1000) and
	 round(normal_abs.z * 1000) == round(up_abs.z * 1000)):
		up = Vector3.UP
	
	look_at(point - normal, up)
