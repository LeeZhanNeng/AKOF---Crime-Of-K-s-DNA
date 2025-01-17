extends Node2D

var TEAMSIDE = 2
var FACING = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(0).position.x += 80

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
