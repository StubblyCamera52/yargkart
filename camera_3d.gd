extends Camera3D

@onready var target = $".."/SpringArm3D/Node3D
@onready var look_target = $".."/CameraLookTarget/Node3D

var camera_rot_target: float = 0

func shake(time: float, strength: float) -> void:
	var elapsed_time := 0.0

	while elapsed_time < time:
		var actual_strength = lerpf(strength, 0, elapsed_time/time)
		var offset := Vector3(randf_range(-actual_strength, actual_strength), randf_range(-actual_strength, actual_strength), 0.0)
		
		transform.origin += offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

func _process(delta: float) -> void:
	global_position = global_position.move_toward(target.global_position, target.global_position.distance_to(global_position)/7)
	look_at(look_target.global_position)
