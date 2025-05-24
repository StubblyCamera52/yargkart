extends Camera3D

@onready var car = $".."/".."

var camera_rot_target: float = 0

func shake(time: float, strength: float) -> void:
	var elapsed_time := 0.0

	while elapsed_time < time:
		var actual_strength = lerpf(strength, 0, elapsed_time/time)
		var offset := Vector3(randf_range(-actual_strength, actual_strength), randf_range(-actual_strength, actual_strength), 0.0)
		
		transform.origin += offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

func _physics_process(delta: float) -> void:
	camera_rot_target = car.rotation.y
	print(car.velocity.length())
	fov = lerpf(75, 100, car.velocity.length()/75)
	rotation.y = car.rotation.y - camera_rot_target
	
