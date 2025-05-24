extends VehicleBody3D

@export var max_speed: float = 30.0

var player: int
var input

func init(player_id: int, device_id: int) -> void:
	player = player_id
	
	input = DeviceInput.new(device_id)

func _physics_process(delta: float) -> void:
	var gas_input_amount = input.get_action_strength("Accelerate")
	var steer_input_amount = input.get_axis("Steer_Left", "Steer_Right")
	
	if Input.is_action_pressed("Accelerate"):
		engine_force = gas_input_amount*1000
	else:
		engine_force = 0
		
	steering = steer_input_amount
