extends Node

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Screenshot"):
		screenshot()

func screenshot() -> void:
	await RenderingServer.frame_post_draw
	
	var viewport = get_viewport()
	var img = viewport.get_texture().get_image()
	var _time = Time.get_datetime_string_from_system(false, true)
	var filename = "D:/Godot/Sceenshots/" + "Screenshot-{0}.png".format({"0": _time}).replace(":", "-")
	img.save_png(filename)
