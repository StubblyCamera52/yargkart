extends RigidBody3D

var player

var reset_state = false
var moveVector: Vector3
var effects_manager

func _integrate_forces(state):
	if reset_state:
		state.transform = Transform3D(basis, moveVector)
		reset_state = false

func move_body(targetPos: Vector3):
	moveVector = targetPos
	reset_state = true

func init(initial_impulse: Vector3, item_model: StringName, player_id: int, effects_manager_node) -> void:
	player = player_id
	apply_central_impulse(initial_impulse)
	effects_manager = effects_manager_node


func _on_activation_area_body_entered(body: Node3D) -> void:
	if body.name == "Car":
		var player_hit_id = body.player
		print(player_hit_id)
		if player_hit_id != player:
			print("hahahha")
			if body.parrying == true:
				print("parry")
				apply_central_impulse(Vector3(-linear_velocity.x*2+sign(linear_velocity.x)*10, linear_velocity.y+5, -linear_velocity.z*2+sign(linear_velocity.x)*10)) # multiply by 2 because just one will cancel out the velocity we already have
				effects_manager.display_impact_frame()
