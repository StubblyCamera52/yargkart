extends Node

@onready var item_base := preload("res://scenes/item.tscn")

@onready var player_manager = $".."/PlayerManager
@onready var effects_manager = $".."/EffectsManager

func use_item(item_type: StringName, player: int, initial_impulse: Vector3, initial_position: Vector3):
	var item = item_base.instantiate()
	add_child(item)
	item.move_body(initial_position)
	item.init(initial_impulse, item_type, player, effects_manager)

func test_use_item():
	use_item("any", 99, Vector3(10, 5, 0), Vector3(0, 3, 0))
