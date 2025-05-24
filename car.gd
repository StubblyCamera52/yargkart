extends VehicleBody3D

@export var max_speed: float = 30.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var gas_amount = Input.get_action_strength("Accelerate")
	
	if Input.is_action_pressed("Accelerate"):
		engine_force = gas_amount*1000
	else:
		engine_force = 0
