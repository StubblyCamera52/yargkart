extends Node

var effects_canvas
var impact_effect

func _ready() -> void:
	effects_canvas = $".."/CanvasLayer
	impact_effect = $".."/CanvasLayer/Impact

func display_impact_frame():
	$ImpactTimer.start()
	impact_effect.visible = true


func _on_impact_timer_timeout() -> void:
	impact_effect.visible = false
