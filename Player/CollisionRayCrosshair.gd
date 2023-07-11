extends RayCast3D

var marker = CSGSphere3D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	#add_child(marker)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	"""
	if is_colliding():
		var collision_point := get_collision_point()
		var collision_normal := get_collision_normal()
		
		marker.global_transform.origin = collision_point
		
		#marker.show()
		marker.hide()
	else:
		marker.hide()
	"""
	if Input.is_action_just_pressed("fire_primary"):
		#var sprite_impact = Sprite3D.new()
		#sprite_impact.texture = "res://Assets/reticle.png"
		
		if is_colliding():
			var impact_sphere = CSGSphere3D.new()
			#add_child(impact_sphere)
			get_tree().get_root().add_child(impact_sphere)
			
			var collision_point := get_collision_point()
			impact_sphere.global_transform.origin = collision_point
			
			impact_sphere.show()
			
			impact_sphere.set_use_collision(true)
			for i in range(1, 32):
				impact_sphere.set_collision_mask_value(i, true)
		
