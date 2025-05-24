extends VehicleBody3D

@export var engine_force_value: float = 30.0
@export var steer_speed: float = 1.5
@export var steer_limit: float = 0.5

var player: int
var input
var steer_target := 0

var previous_speed = linear_velocity.length()

func init(player_id: int, device_id: int) -> void:
	player = player_id
	
	input = DeviceInput.new(device_id)

func _physics_process(delta: float) -> void:
	var gas_input_amount = input.get_action_strength("Accelerate")
	steer_target = input.get_axis("Steer_Right", "Steer_Left")*2
	steer_target *= steer_limit
	
	if input.is_action_pressed("Accelerate"):
		engine_force = engine_force_value
	else:
		engine_force = 0.0
		
	steering = move_toward(steering, steer_target, delta*steer_speed)
	
	previous_speed = linear_velocity.length()
