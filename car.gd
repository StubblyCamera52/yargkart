extends CharacterBody3D

@export var engine_force_value: float = 2.5
@export var steer_speed: float = 1.5
@export var steer_limit: float = 0.5
@export var decel: float = 3
@export var gravity: float = 60.0
@export var speed_limit: float = 4500.0 # miles per hour lmao
@export var wheel_rotate_speed: float = 2

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
@onready var groundRay = $RayCast3D
@onready var kartMesh = $KartMesh
var wheel_default_y : float = deg_to_rad(90)
var car_rotation_dir := 0.0

@onready var checkpoint0 = $yargcheckpoint
@onready var checkpoint1 = $yargcheckpoint2
@onready var checkpoint2 = $yargcheckpoint3
@onready var checkpoint3 = $yargcheckpoint4
@onready var checkpoint4 = $yargcheckpoint5
@onready var checkpoint5 = $yargcheckpoint6
@onready var checkpoint6 = $yargcheckpoint7
@onready var checkpoint7 = $yargcheckpoint8
@onready var checkpoint8 = $yargcheckpoint9
@onready var checkpoint9 = $yargcheckpoint10
var checkpoints = [
	checkpoint0,checkpoint1,checkpoint2,checkpoint3,checkpoint4,
	checkpoint5,checkpoint6,checkpoint7,checkpoint8,checkpoint9]

var previous_speed = velocity.length()

func init(player_id: int, device_id: int, item_manager_node) -> void:
	player = player_id
	
	item_manager = item_manager_node
	print(device_id)
	print(player_id)
	
	kartMesh.set_surface_override_material(0, load("res://models/kart"+str(player)+"Material.tres"))
	input = DeviceInput.new(device_id)
	
func rotate_wheels_x(dir: float, delta: float) -> void:
	wheelFL.rotation.x = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelFR.rotation.x = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelBL.rotation.x = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelBR.rotation.x = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	
func rotate_wheels_y(dir: float, delta: float) -> void:
	wheelFL.rotation.y = move_toward(wheelFL.rotation.y, deg_to_rad(90)+dir, delta*wheel_rotate_speed)
	wheelFR.rotation.y = move_toward(wheelFR.rotation.y, deg_to_rad(-90)+dir, delta*wheel_rotate_speed)
	
func rotate_wheels_z(dir: float, delta: float) -> void:
	wheelFL.rotation.z = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelFR.rotation.z = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelBL.rotation.z = move_toward(player_vel, dir, delta*wheel_rotate_speed)
	wheelBR.rotation.z = move_toward(player_vel, dir, delta*wheel_rotate_speed)

func _physics_process(delta: float) -> void:
	wheel_rotate_speed = 0.5*deg_to_rad(car_rotation_dir)**2+10
	car_rotation_dir += input.get_axis("Steer_Right", "Steer_Left")*wheel_rotate_speed
	var car_normalize_spd = abs(player_vel*0.05*deg_to_rad(car_rotation_dir))
	car_rotation_dir = move_toward(car_rotation_dir, 0, delta*car_normalize_spd)
	if car_rotation_dir > 90:
		car_rotation_dir = 90
	if car_rotation_dir < -90:
		car_rotation_dir = -90
	var gas_input_amount = input.get_action_strength("Accelerate")
	steer_speed = player_vel*0.002
	if steer_speed > 4:
		steer_speed = 4
#	steer_target = input.get_axis("Steer_Right", "Steer_Left")*steer_speed
	steer_target = deg_to_rad(car_rotation_dir)*5
	steer_target *= steer_limit
	
	if input.is_action_pressed("Accelerate"):
		engine = clamp(engine, -5, 3000)
		engine += delta*engine_force_value
	elif input.is_action_pressed("Brake"):
		engine = clamp(engine, -1500, 5)
		engine -= delta*engine_force_value
	else:
		engine = 0.0
		if abs(player_vel) <= 5:
			player_vel = 0
	engine = clamp(engine, -1500, 3000)
		
	if is_on_floor():
		decel = 30
		gravity = 60
	else:
		decel = 5
		velocity.y -= gravity*delta
		gravity += 10
		if groundRay.is_colliding() and position.y-groundRay.get_collision_point().y>0.25:
			position.y=groundRay.get_collision_point().y+0.01
		velocity.y = clamp(velocity.y, -75, 75)
		
	steer = move_toward(steer, steer_target, delta*steer_speed)
	rotation.y+=steer_target*delta*steer_speed*0.1
	if is_on_floor():
		velocity.y=0
		player_vel += engine*delta
		if player_vel > speed_limit:
			player_vel = speed_limit
	player_vel = move_toward(player_vel, 0, decel*delta)
	velocity.x = cos(rotation.y)*player_vel*delta
	velocity.z = -sin(rotation.y)*player_vel*delta
	rotate_wheels_x(engine*delta, delta)
	rotate_wheels_y(deg_to_rad(car_rotation_dir)*0.5, delta)
	move_and_slide()
	
	if is_on_wall():
		player_vel = 0
	
	#items
	if input.is_action_just_pressed(&"Action"):
		item_manager.use_item(&"Bomb", player, Vector3(cos(rotation.y)*20, 5, -sin(rotation.y)*20)+velocity, position)
	
	if input.is_action_just_pressed(&"Parry") and parry_allowed:
		$ParryCooldown.start()
		$ParryDebounce.start()
		parrying = true
		#parry_allowed = false
	
	previous_speed = 0
	
	previous_speed = velocity.length()
	
	var score: int
	var next_checkpoint: int = 0
	var checkpoint = checkpoints[next_checkpoint]
	var next_area = checkpoint.Area3D
	if next_area.area_entered(self.Area3D):
		print("checkpoint passed")
		score += 1
		next_checkpoint = score % 10
	print(score)
	print(next_checkpoint)

func _on_parry_cooldown_timeout() -> void:
	parry_allowed = true


func _on_parry_debounce_timeout() -> void:
	parrying = false
