extends Control

@onready var game = load("res://Assets/System/MainGame.tscn")
@onready var settings = load("res://Assets/Menu/Settings.tscn")

@onready var first: Button
@onready var SFX: AudioStreamPlayer = $SFX

@onready var container = $PanelContainer/VBoxContainer

var TIME: int = -1
var TWEEN_ACTIVE: bool = false
var PRESSED_BUTTON: String

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
		button.get_theme_stylebox("normal").set_content_margin_all(button.get_theme_font_size("font_size") / 7.0)
		button.get_theme_stylebox("pressed").set_content_margin_all(button.get_theme_font_size("font_size") / 7.0)
			
		if button.has_focus():
			button.text = text.to_upper()
			button.get_theme_stylebox("normal").bg_color = Color(1, 1, 1, (42 + 16 * sin(2.0 * PI * TIME / (9.5 * 4.0))) / 255.0)
		else:
			button.text = text.to_lower()
			button.get_theme_stylebox("normal").bg_color = Color(1, 1, 1, 0)
			
		if button.name == "Exit" and Input.is_action_just_pressed("ui_cancel"):
			button.grab_focus()
			_on_exit_pressed()
			
func _on_start_pressed() -> void:
	if TWEEN_ACTIVE:
		return
	SFX.play_sfx("Press")
	TWEEN_ACTIVE = true
	PRESSED_BUTTON = "Start"
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self,"modulate:v",0,.5)
	tween.tween_callback(start)

func _on_settings_pressed() -> void:
	if TWEEN_ACTIVE:
		return
	SFX.play_sfx("Press")
	TWEEN_ACTIVE = true
	PRESSED_BUTTON = "Settings"
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self,"modulate:v",0,.5)
	tween.tween_callback(setting)

func _on_exit_pressed() -> void:
	if TWEEN_ACTIVE:
		return 
	SFX.play_sfx("Press")
	TWEEN_ACTIVE = true
	PRESSED_BUTTON = "Exit"
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self,"modulate:v",0,.5)
	tween.tween_callback(exit)

func _on_focus_entered() -> void:
	if TWEEN_ACTIVE:
		return
	if not Input.is_action_pressed("ui_cancel"):
		SFX.play_sfx("Toggle")

func start() -> void:
	TWEEN_ACTIVE = false
	get_node("/root/MenuBgm").queue_free()
	get_tree().change_scene_to_packed(game)

func setting() -> void:
	TWEEN_ACTIVE = false
	get_tree().change_scene_to_packed(settings)

func exit() -> void:
	TWEEN_ACTIVE = false
	get_tree().quit()
