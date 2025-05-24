extends CharacterBody3D

@export var engine_force_value: float = 30.0
@export var steer_speed: float = 1.5
@export var steer_limit: float = 0.5
@export var decel: float = 30.0
@export var gravity: float = 30.0

var item_manager

var player: int
var input
var steer_target := 0
var engine
var steer := 0
var player_vel := 0.0

var previous_speed = velocity.length()

func init(player_id: int, device_id: int, item_manager_node) -> void:
	player = player_id
	
	item_manager = item_manager_node
	
	input = DeviceInput.new(device_id)

func _physics_process(delta: float) -> void:
	var gas_input_amount = input.get_action_strength("Accelerate")
	steer_target = input.get_axis("Steer_Right", "Steer_Left")*2
	steer_target *= steer_limit
	
	if input.is_action_pressed("Accelerate"):
		engine = engine_force_value
	else:
		engine = 0.0
		
	# Items
	if input.is_action_just_pressed(&"Action"):
		pass
		
	
	if is_on_floor():
		pass
	else:
		velocity.y-=gravity*delta
	steer = move_toward(steer, steer_target, delta*steer_speed)
	rotation.y+=steer_target*delta
	player_vel += engine*delta
	player_vel = move_toward(player_vel, 0, decel*delta)
	velocity.x = cos(rotation.y)*player_vel*delta
	velocity.z = -sin(rotation.y)*player_vel*delta
	move_and_slide()
	
	previous_speed = 0
	
	previous_speed = velocity.length()
