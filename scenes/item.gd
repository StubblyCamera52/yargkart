extends RigidBody3D

var player

var reset_state = false
var moveVector: Vector3

func _integrate_forces(state):
	if reset_state:
		state.transform = Transform3D(basis, moveVector)
		reset_state = false

func move_body(targetPos: Vector3):
	moveVector = targetPos
	reset_state = true

func init(initial_impulse: Vector3, item_model: StringName, player_id: int) -> void:
	player = player_id
	apply_central_impulse(initial_impulse)
