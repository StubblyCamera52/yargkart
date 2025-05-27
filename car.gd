extends CharacterBody3D

@export var engine_force_value: float = 2.5
@export var steer_speed: float = 1.5
@export var steer_limit: float = 0.5
@export var decel: float = 3
@export var gravity: float = 60.0
@export var speed_limit: float = 4500.0 # miles per hour lmao
@export var wheel_rotate_speed: float = 2
# Drifting settings
@export var drift_steering_mult: float = 2.0
@export var drift_slide_force: float = 30.0
@export var drift_forward_vel_reduction_mult: float = 0.8

@onready var wheelFL = $FLWheelModel
@onready var wheelFR = $FrWheelModel
@onready var wheelBL = $BLWheelModel
@onready var wheelBR = $BRWheelModel
@onready var groundRay = $RayCast3D
@onready var kartMesh = $KartMesh
@onready var racerModel = $Racer

var parrying = false
var parry_allowed = true

var item_manager

var player: int
var input
var steer_target := 0
var engine
var steer := 0
var player_vel := 0.0
var previous_speed_limit := 0.0

#Drifting variables
var player_lateral_vel := 0.0
var is_drifting: bool = false
var drift_direction: int = 0 # -1 for left +1 for right
var drift_timer: float = 0

var wheel_default_y : float = deg_to_rad(90)
var car_rotation_dir := 0.0

# Checkpoint Variables
var checkpoints = []
var next_checkpoint
var next_checkpoint_id: int = 0
var score: int = 0
var next_area
var check_for_point = true

var previous_speed = velocity.length()

func init(player_id: int, device_id: int, item_manager_node, checkpoints_list) -> void:
	player = player_id
	checkpoints = checkpoints_list
	next_checkpoint = checkpoints[0]
	next_area = next_checkpoint.get_node_or_null("Area3D")
	#print(next_checkpoint)
	
	item_manager = item_manager_node
	print(device_id)
	print(player_id)
	
	kartMesh.set_surface_override_material(0, load("res://models/kart"+str(player)+"Material.tres"))
	racerModel.get_node("Armature_001/Skeleton3D/Head").set_surface_override_material(0, load("res://models/kart"+str(player)+"Material.tres"))
	racerModel.get_node("Armature_001/Skeleton3D/Body").set_surface_override_material(0, load("res://models/kart"+str(player)+"Material.tres"))
	racerModel.get_node("Armature_001/Skeleton3D/Scarf").set_surface_override_material(0, load("res://models/kart"+str(player)+"Material.tres"))
	input = DeviceInput.new(device_id)
	racerModel.get_node("AnimationPlayer").play("Steer")
	
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
	$Camera3D/CanvasLayer/LapCounter.text = "Player " + str(player)+" - Left Stick to turn, A to accelerate, B to brake, Start to respawn!"
	wheel_rotate_speed = 0.5*deg_to_rad(car_rotation_dir)**2+10
	car_rotation_dir += input.get_axis("Steer_Right", "Steer_Left")*wheel_rotate_speed
	var car_normalize_spd = abs(player_vel*3*deg_to_rad(car_rotation_dir))
	car_rotation_dir = move_toward(car_rotation_dir, 0, delta*car_normalize_spd)
	if car_rotation_dir > 90:
		car_rotation_dir = 90
	if car_rotation_dir < -90:
		car_rotation_dir = -90
		
		
	# Steering
	if is_drifting:
		steer_speed = player_vel*0.12*drift_steering_mult
		if steer_speed > 4*drift_steering_mult:
			steer_speed = 4*drift_steering_mult
	else:
		steer_speed = player_vel*0.12
		if steer_speed > 4:
			steer_speed = 4
#	steer_target = input.get_axis("Steer_Right", "Steer_Left")*steer_speed
	steer_target = deg_to_rad(car_rotation_dir)*5
	steer_target *= steer_limit
	
	if input.is_action_pressed("Join"):
		global_position = Vector3(randf()*50-25, 2, randf()*50-25)
		player_vel = 0
		
	
	if input.is_action_pressed("Accelerate"):
		engine = clamp(engine, -5, 200)
		engine += delta*engine_force_value
	elif input.is_action_pressed("Brake"):
		engine = clamp(engine, -100, 5)
		engine -= delta*engine_force_value
	else:
		engine = 0.0
		if abs(player_vel) <= 5:
			player_vel = 0
	engine = clamp(engine, -100, 200)
	
	player_lateral_vel = 0
	
	if input.is_action_just_pressed("Drift"):
		is_drifting = true
		previous_speed_limit = speed_limit
		speed_limit *= drift_forward_vel_reduction_mult
		drift_timer = 0
		drift_direction = sign(input.get_axis("Steer_Right", "Steer_Left"))
		#print(sign(input.get_axis("Steer_Right", "Steer_Left")))
	if is_drifting:
		if input.get_axis("Steer_Right", "Steer_Left") == 0:
			speed_limit = previous_speed_limit
			drift_timer = 0
			is_drifting = false
			drift_direction = 0
		else:
			player_lateral_vel = drift_direction*drift_slide_force*(player_vel/speed_limit)
			#print(player_lateral_vel)
	
	if input.is_action_just_released("Drift") and is_drifting == true:
		speed_limit = previous_speed_limit
		drift_timer = 0
		is_drifting = false
		drift_direction = 0
		
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
	#print(player_vel)
	#print(player_lateral_vel)
	velocity.x = cos(rotation.y)*player_vel
	velocity.z = -sin(rotation.y)*player_vel
	velocity += Vector3(0, 0, player_lateral_vel).rotated(Vector3.UP, rotation.y)
	rotate_wheels_x(engine*delta, delta)
	rotate_wheels_y(deg_to_rad(car_rotation_dir)*0.5, delta)
	racerModel.get_node("AnimationPlayer").seek(1.27085-car_rotation_dir*0.01,false,false)
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
	
	if next_area.overlaps_area($CheckpointCollider) and check_for_point:
		print("checkpoint passed")
		score += 1
		next_checkpoint_id += 1
		if next_checkpoint_id > checkpoints.size():
			next_checkpoint_id = 0
		next_checkpoint = checkpoints[next_checkpoint_id]
		next_area = next_checkpoint.get_node_or_null("Area3D")
		#print(score)
		#print(next_checkpoint)
		#print(next_area.get_parent().name)

func _on_parry_cooldown_timeout() -> void:
	parry_allowed = true


func _on_parry_debounce_timeout() -> void:
	parrying = false
