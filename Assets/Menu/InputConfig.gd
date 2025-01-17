extends Control

@onready var settings = load("res://Assets/Menu/Settings.tscn")

@onready var first: Button
@onready var SFX: AudioStreamPlayer = $SFX

@onready var container = $PanelContainer/VBoxContainer
@onready var containerP1 = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer
@onready var containerP2 = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer2

var TIME: int = -1
var TWEEN_ACTIVE: bool = false
var PRESSED_BUTTON: String
var INPUT_SETTING
var INPUT_CHECK

func _ready() -> void:
	for i in containerP1.get_child_count():
		if containerP1.get_child(i).get_child(0) is Button:
			first = containerP1.get_child(i).get_child(0)
			break
		else:
			continue
			
	first.grab_focus()
	
	container.get_node("ScrollContainer").follow_focus = true
	
	var numButtons = container.get_child_count()
	for i in numButtons:
		var button: Button
		if container.get_child(i) is Button:
			button = container.get_child(i)
		else:
			continue
		button.connect("focus_entered", _on_focus_entered)
		
	var Player1 = containerP1.get_child_count()
	for i in Player1:
		var button: Button
		var bName: String
		if containerP1.get_child(i) is HBoxContainer:
			button = containerP1.get_child(i).get_child(0)
			bName = containerP1.get_child(i).name
		else:
			continue
		var event = InputMap.action_get_events(bName)[0].keycode
		var input = OS.get_keycode_string(event)
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		button.get_child(0).text = input.to_lower()
		button.connect("focus_entered", _on_focus_entered)
		button.connect("pressed", _set_input.bind(button))
			
	var Player2 = containerP2.get_child_count()
	for i in Player2:
		var button: Button
		var bName: String
		if containerP2.get_child(i) is HBoxContainer:
			button = containerP2.get_child(i).get_child(0)
			bName = containerP1.get_child(i).name + "2"
		else:
			continue
		var event = InputMap.action_get_events(bName)[0].keycode
		var input = OS.get_keycode_string(event)
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		button.get_child(0).text = input.to_lower()
		button.connect("focus_entered", _on_focus_entered)
		button.connect("pressed", _set_input.bind(button))
		
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
	elif INPUT_SETTING:
		var bName: String
		if INPUT_SETTING.get_parent().get_parent().name == "VBoxContainer":
			bName = INPUT_SETTING.get_parent().name
		else:
			bName = INPUT_SETTING.get_parent().name + "2"
		INPUT_SETTING.grab_focus()
		INPUT_SETTING.get_theme_stylebox("normal").bg_color = Color(1, 1, 1, (42 + 16 * sin(2.0 * PI * TIME / (9.5 * 4.0))) / 255.0)
		var label = INPUT_SETTING.get_child(0)
		label.text = "..."
		if Input.is_action_pressed("ui_cancel"):
			label.text = OS.get_keycode_string(InputMap.action_get_events(bName)[0].keycode).to_lower()
			INPUT_SETTING = null
			INPUT_CHECK = null
		elif INPUT_CHECK:
			InputMap.action_erase_events(bName)
			InputMap.action_add_event(bName, INPUT_CHECK)
			label.text = OS.get_keycode_string(INPUT_CHECK.keycode).to_lower()
			INPUT_SETTING = null
			INPUT_CHECK = null
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
			
		if button.name == "Return" and Input.is_action_just_pressed("ui_cancel"):
			button.grab_focus()
			_on_return_pressed()
			
	var Player1 = containerP1.get_child_count()
	for i in Player1:
		var button: Button
		if containerP1.get_child(i) is HBoxContainer:
			button = containerP1.get_child(i).get_child(0)
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
		else:
			button.text = text.to_lower()
			button.get_theme_stylebox("normal").bg_color = Color(1, 1, 1, 0)
			
		if button.name == "Return" and Input.is_action_just_pressed("ui_cancel"):
			button.grab_focus()
			_on_return_pressed()
			
	var Player2 = containerP2.get_child_count()
	for i in Player2:
		var button: Button
		if containerP2.get_child(i) is HBoxContainer:
			button = containerP2.get_child(i).get_child(0)
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
		else:
			button.text = text.to_lower()
			button.get_theme_stylebox("normal").bg_color = Color(1, 1, 1, 0)
			
		if button.name == "Return" and Input.is_action_just_pressed("ui_cancel"):
			button.grab_focus()
			_on_return_pressed()

func _unhandled_key_input(event: InputEvent) -> void:
	if INPUT_SETTING and event.pressed and event.echo == false:
		INPUT_CHECK = event
	else:
		INPUT_CHECK = null

func _set_input(button: Button) -> void:
	SFX.play_sfx("Press")
	INPUT_SETTING = button

func _on_return_pressed() -> void:
	if TWEEN_ACTIVE or INPUT_SETTING:
		return 
	SFX.play_sfx("Press")
	TWEEN_ACTIVE = true
	PRESSED_BUTTON = "Return"
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self,"modulate:v",0,.5)
	tween.tween_callback(return_to_settings)

func _on_focus_entered() -> void:
	if TWEEN_ACTIVE or INPUT_SETTING:
		return
	if not Input.is_action_pressed("ui_cancel"):
		SFX.play_sfx("Toggle")

func return_to_settings() -> void:
	get_tree().change_scene_to_packed(settings)
