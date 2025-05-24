extends CharacterBody3D

@export var engine_force_value: float = 30.0
@export var steer_speed: float = 1.5
@export var steer_limit: float = 0.5
@export var decel: float = 30.0
@export var gravity: float = 30.0
@export var speed_limit: float = 4500.0 # miles per hour lmao
@export var wheel_rotate_speed: float = 0.01

var parrying = false
var parry_allowed = true

var item_manager

var player: int
var input
var steer_target := 0
var engine
var steer := 0
var player_vel := 0.0
@onready var wheelFL = $FLWheelModel
@onready var wheelFR = $FrWheelModel
@onready var wheelBL = $BLWheelModel
@onready var wheelBR = $BRWheelModel

var previous_speed = velocity.length()

func init(player_id: int, device_id: int, item_manager_node) -> void:
	player = player_id
	
	item_manager = item_manager_node
	
	input = DeviceInput.new(device_id)
	
func rotate_wheels_x(dir: float, delta: float) -> void:
	wheelFL.rotation.x = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelFR.rotation.x = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelBL.rotation.x = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelBR.rotation.x = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	
func rotate_wheels_y(dir: float, delta: float) -> void:
	wheelFL.rotation.y = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelFR.rotation.y = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelBL.rotation.y = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelBR.rotation.y = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	
func rotate_wheels_z(dir: float, delta: float) -> void:
	wheelFL.rotation.z = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelFR.rotation.z = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelBL.rotation.z = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelBR.rotation.z = move_toward(player_vel, dir, delta*wheel_rotate_speed)

func _physics_process(delta: float) -> void:
	var gas_input_amount = input.get_action_strength("Accelerate")
	steer_speed = player_vel*0.005
	if steer_speed > 10:
		steer_speed = 10
	steer_target = input.get_axis("Steer_Right", "Steer_Left")*steer_speed
	steer_target *= steer_limit
	
	if input.is_action_pressed("Accelerate"):
		engine = engine_force_value
	else:
		engine = 0.0
		
	if is_on_floor():
		pass
	else:
		velocity.y-=gravity*delta
		
	steer = move_toward(steer, steer_target, delta*steer_speed)
	rotation.y+=steer_target*delta
	if is_on_floor():
		player_vel += engine*delta
		if player_vel > speed_limit:
			player_vel = speed_limit
	player_vel = move_toward(player_vel, 0, decel*delta)
	velocity.x = cos(rotation.y)*player_vel*delta
	velocity.z = -sin(rotation.y)*player_vel*delta
	
	rotate_wheels_x(engine*delta, delta)
	move_and_slide()
	
	#items
	if input.is_action_just_pressed(&"Action"):
		item_manager.use_item(&"any", player, Vector3(cos(rotation.y)*10, 5, -sin(rotation.y)*10), position)
	
	if input.is_action_just_pressed(&"Parry") and parry_allowed:
		$ParryCooldown.start()
		$ParryDebounce.start()
		parrying = true
		#parry_allowed = false
	
	previous_speed = 0
	
	previous_speed = velocity.length()

# to implement:
	# speed cap ✔
	# do not accel if in air ✔
	# make turning, like, good ✖
	# make turning, like, passable ✔
	# wheel crap ➖
	# make turning not stop immediately


func _on_parry_cooldown_timeout() -> void:
	parry_allowed = true


func _on_parry_debounce_timeout() -> void:
	parrying = false
