extends Node3D

@onready var player_manager = $PlayerManager
@onready var item_manager = $ItemManager

var player_nodes := {}

func _ready() -> void:
	player_manager.player_joined.connect(spawn_player)

func spawn_player(player: int) -> void:
	var kart = preload("res://car.tscn")
	
	var player_kart = kart.instantiate()
	
	add_child(player_kart)
	
	player_kart.position = Vector3(randf()*50-25, 2, randf()*50-25)
	
	var player_device = player_manager.get_device_for_player(player)
	
	player_kart.init(player, player_device, item_manager)
	
	player_nodes[player] = player_kart

func _process(delta: float) -> void:
	var unclaimed_devices = player_manager.scan_for_unclaimed_input_devices()
	if unclaimed_devices.size() > 0:
		for device in unclaimed_devices:
			if MultiplayerInput.is_action_just_pressed(device, "Join"):
				player_manager.join(device)
