extends Button


signal value_changed(variable_call: String, value_call)
signal focusing_on_button(description: String)

@export var variable_representing_button: String = ""
@export var array_representing_button: String = ""
@export_multiline var description_setting: String = ""

@onready var left = $Left
@onready var right = $Right
@onready var value = $Value


var key_array_settings: Array
var key_settings: int
func visibility_changed_global_settings():
	set_value()

func buttons_pressed(is_left: bool):
	if is_left:
		key_settings -= 1
		if key_settings < 0:
			key_settings = Setting.get(array_representing_button).size() - 1
	else: 
		key_settings += 1
		if key_settings > Setting.get(array_representing_button).size() - 1:
			key_settings = 0
	change_value()

func change_value():
	set_value()
	value_changed.emit(variable_representing_button,\
		Setting.get(array_representing_button)[key_array_settings[key_settings]])


func set_value():
	if variable_representing_button.length() == 0 or array_representing_button.length() == 0:
		return
	if key_array_settings.size() <= 0:
		return
	var key_value = key_array_settings[key_settings]
	if Setting.LANGUAGE_TYPE[Setting.global_language].has(key_array_settings[key_settings]):
		value.text = str(Setting.LANGUAGE_TYPE[Setting.global_language][key_value])
	else:
		value.text = str(key_value)




func _ready():
	if variable_representing_button.length() == 0 and array_representing_button.length() == 0:
		return
	key_array_settings = Setting.get(array_representing_button).keys()
	
	var representing_variable = Setting.get(variable_representing_button)
	var representing_array = Setting.get(array_representing_button)
	var local_key = representing_array.find_key(representing_variable)
	key_settings = key_array_settings.find(local_key)
	left.connect("pressed", left_pressed)
	right.connect("pressed", right_pressed)
	set_value()


func left_pressed():
	buttons_pressed(true)


func right_pressed():
	buttons_pressed(false)


func _on_visibility_changed():
	set_value()


func _on_focus_entered():
	focusing_on_button.emit(description_setting)


func _on_focus_exited():
	pass


func _on_mouse_entered():
	focusing_on_button.emit(description_setting)


func _on_mouse_exited():
	pass
