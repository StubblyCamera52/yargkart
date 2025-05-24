extends Camera3D

@export var follow_target: Node3D
@export var look_target: Node3D

func shake(time: float, strength: float) -> void:
	var elapsed_time := 0.0

	while elapsed_time < time:
		var actual_strength = lerpf(strength, 0, elapsed_time/time)
		var offset := Vector3(randf_range(-actual_strength, actual_strength), randf_range(-actual_strength, actual_strength), 0.0)
		
		transform.origin += offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

func _process(delta: float) -> void:
	#print(car.velocity.length())
	global_position = global_position.move_toward(follow_target.global_position+Vector3(-cos(follow_target.rotation.y)*4, 2.5, sin(follow_target.rotation.y)*4), delta*50)
	if global_position.distance_to(follow_target.global_position) > 7:
		global_position
	look_at(look_target.global_position)
	#fov = lerpf(75, 100, follow_target.velocity.length()/75)
	
