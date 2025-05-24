extends RigidBody3D

var player

func init(initial_impulse: Vector3, item_model: StringName, player_id: int) -> void:
	player = player_id
	apply_central_impulse(initial_impulse)
