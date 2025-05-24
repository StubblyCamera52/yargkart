extends RigidBody3D

func init(initial_impulse: Vector3, item_model: StringName ) -> void:
	apply_central_impulse(initial_impulse)
