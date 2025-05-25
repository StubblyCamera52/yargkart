extends Node3D

@onready var player_manager = $PlayerManager
@onready var item_manager = $ItemManager

var player_nodes := {}

@onready var render_target = $RenderTarget

func _ready() -> void:
	player_manager.player_joined.connect(spawn_player)

func spawn_player(player: int) -> void:
	var kart = preload("res://car.tscn")
	
	var player_kart = kart.instantiate()
	
	var sub_view_container = SubViewportContainer.new()
	sub_view_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub_view_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sub_view_container.stretch = true
	sub_view_container.name = str(player)
	render_target.add_child(sub_view_container)
	
	var sub_view = SubViewport.new()
	sub_view_container.add_child(sub_view)
	
	sub_view.add_child(player_kart)
	
	player_kart.position = Vector3(randf()*50-25, 2, randf()*50-25)
	
	var player_device = player_manager.get_device_for_player(player)
	
	player_kart.init(player, player_device, item_manager)
	
	player_nodes[player] = player_kart
	
	render_target.columns = ceil(sqrt(player_nodes.size()))

func _process(delta: float) -> void:
	var unclaimed_devices = player_manager.scan_for_unclaimed_input_devices()
	if unclaimed_devices.size() > 0:
		for device in unclaimed_devices:
			if MultiplayerInput.is_action_just_pressed(device, "Join"):
				player_manager.join(device)
