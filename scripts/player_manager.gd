extends Node

signal player_joined(player)
signal player_left(player)

var players := {}

func join(device: int):
	var player = players.size()+1 
	players[player] = {"device": device}
	player_joined.emit(player)

func get_device_for_player(player: int):
	return get_player_data(player, "device")
		
func get_player_data(player: int, key: StringName):
	if players.has(player) and players[player].has(key):
		return players[player][key]
	return null

func is_input_device_claimed(device: int) -> bool:
	for player in players:
		var d = get_device_for_player(player)
		if device == d: return true
	return false

func scan_for_unclaimed_input_devices():
	var devices = Input.get_connected_joypads()
	devices.append(-1) #keyboard is -1
	
	return devices.filter(func(device): return !is_input_device_claimed(device))
