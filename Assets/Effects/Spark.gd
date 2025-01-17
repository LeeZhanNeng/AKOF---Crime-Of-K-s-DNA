extends Node2D

@onready var anim_player = $AnimationPlayer

var POS: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = POS

func _play_spark(SPARK: String) -> void:
	z_index = 4096
	anim_player.play(SPARK)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
