extends Node3D

@onready var PlayerManager = $PlayerManager

var player_nodes := {}

func spawn_player() -> void:
	var kart = preload("res://car.tscn")
	
	var player_kart = kart.instantiate()
	
	add_child(player_kart)
