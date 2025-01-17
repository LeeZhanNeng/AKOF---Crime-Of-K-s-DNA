extends Control

@onready var menu = load("res://Assets/Menu/MainMenu.tscn")
@onready var config = load("res://Assets/Menu/InputConfig.tscn")

@onready var first: Button
@onready var SFX: AudioStreamPlayer = $SFX

@onready var container = $PanelContainer/VBoxContainer

var TIME: int = -1
var TWEEN_ACTIVE: bool = false
var PRESSED_BUTTON: String

var master_volume: float = ceil(floor(db_to_linear(AudioServer.get_bus_volume_db(0)) * 10000) / 100.0)
var music_volume: float = ceil(floor(db_to_linear(AudioServer.get_bus_volume_db(1)) * 10000) / 100.0)
var sfx_volume: float = ceil(floor(db_to_linear(AudioServer.get_bus_volume_db(2)) * 10000) / 100.0)

func _ready() -> void:
	for i in container.get_child_count():
		if container.get_child(i) is Button:
			first = container.get_child(i)
			break
		else:
			continue
			
	first.grab_focus()
	
	var numButtons = container.get_child_count()
	for i in numButtons:
		var button: Button
		if container.get_child(i) is Button:
			button = container.get_child(i)
		else:
			continue
		button.connect("focus_entered", _on_focus_entered)
		if button.name == "Master Volume":
			button.get_child(0).text = str(master_volume)
		elif button.name == "Music Volume":
			button.get_child(0).text = str(music_volume)
		elif button.name == "SFX Volume":
			button.get_child(0).text = str(sfx_volume)

func _process(delta: float) -> void:
	TIME += 1
	
	if PRESSED_BUTTON:
		var numButtons = container.get_child_count()
		for i in numButtons:
			var button: Button
			if container.get_child(i) is Button:
				button = container.get_child(i)
			else:
				continue
			var text = button.text
			if button.name == PRESSED_BUTTON:
				button.text = text.to_upper()
				button.get_theme_stylebox("normal").bg_color = Color(1, 1, 1, (42 + 16 * sin(2.0 * PI * TIME / (9.5 * 4.0))) / 255.0)
			else:
				button.text = text.to_lower()
				button.get_theme_stylebox("normal").bg_color = Color(1, 1, 1, 0)
		return	
		
	var numButtons = container.get_child_count()
	for i in numButtons:
		var button: Button
		if container.get_child(i) is Button:
			button = container.get_child(i)
		else:
			continue
		var text = button.text
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.get_theme_stylebox("normal").content_margin_top = button.get_theme_font_size("font_size") / 7.0
		button.get_theme_stylebox("normal").content_margin_bottom = button.get_theme_font_size("font_size") / 7.0
		button.get_theme_stylebox("pressed").content_margin_top = button.get_theme_font_size("font_size") / 7.0
		button.get_theme_stylebox("pressed").content_margin_bottom = button.get_theme_font_size("font_size") / 7.0
			
		if button.has_focus():
			button.text = text.to_upper()
			button.get_theme_stylebox("normal").bg_color = Color(1, 1, 1, (42 + 16 * sin(2.0 * PI * TIME / (9.5 * 4.0))) / 255.0)
			var value: int
			if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				value = Input.get_axis("ui_left", "ui_right")
				if Input.is_key_pressed(KEY_SHIFT):
					value = value * 10
			if button.name == "Master Volume":
				master_volume += value
				if master_volume < 0:
					master_volume = 0
				elif master_volume > 100:
					master_volume = 100
				button.get_child(0).text = str(master_volume)
			elif button.name == "Music Volume":
				music_volume += value
				if music_volume < 0:
					music_volume = 0
				elif music_volume > 100:
					music_volume = 100
				button.get_child(0).text = str(music_volume)
			elif button.name == "SFX Volume":
				sfx_volume += value
				if sfx_volume < 0:
					sfx_volume = 0
				elif sfx_volume > 100:
					sfx_volume = 100
				button.get_child(0).text = str(sfx_volume)
		else:
			button.text = text.to_lower()
			button.get_theme_stylebox("normal").bg_color = Color(1, 1, 1, 0)
			
		if button.name == "Return" and Input.is_action_just_pressed("ui_cancel"):
			button.grab_focus()
			_on_return_pressed()
			
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume/100.0))
	AudioServer.set_bus_volume_db(1, linear_to_db(music_volume/100.0))
	AudioServer.set_bus_volume_db(2, linear_to_db(sfx_volume/100.0))

func _on_input_config_pressed() -> void:
	if TWEEN_ACTIVE:
		return 
	SFX.play_sfx("Press")
	TWEEN_ACTIVE = true
	PRESSED_BUTTON = "Input Config"
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self,"modulate:v",0,.5)
	tween.tween_callback(input_config)

func _on_return_pressed() -> void:
	if TWEEN_ACTIVE:
		return 
	SFX.play_sfx("Press")
	TWEEN_ACTIVE = true
	PRESSED_BUTTON = "Return"
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self,"modulate:v",0,.5)
	tween.tween_callback(return_to_menu)

func _on_focus_entered() -> void:
	if TWEEN_ACTIVE:
		return
	if not Input.is_action_pressed("ui_cancel"):
		SFX.play_sfx("Toggle")

func input_config() -> void:
	get_tree().change_scene_to_packed(config)

func return_to_menu() -> void:
	get_tree().change_scene_to_packed(menu)
