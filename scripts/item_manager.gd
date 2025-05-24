extends Node

@onready var item_base := preload("res://scenes/item.tscn")

@onready var player_manager = $PlayerManager

func use_item(item_type: StringName, player: int, initial_impulse: Vector3, initial_position: Vector3):
	var item = item_base.instantiate()
	add_child(item)
	item.move_body(initial_position)
	item.init(initial_impulse, item_type, player)
