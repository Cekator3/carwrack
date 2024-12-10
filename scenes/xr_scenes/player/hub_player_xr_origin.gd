extends XROrigin3D

@onready var xr_camera := get_node_or_null("XRCamera3D")
@onready var left: XRController3D = $Left
@onready var right: XRController3D = $Right

#const LIST_OF_LEVELS_RESOURCE = preload("res://scenes/levels/list_of_levels_resource.tres")

var music_edit_mode: bool = false
var playlist_edit_mode: bool = false

func _ready():
	Global.player_xr_origin = self
	
	Global.player_instantiated.emit()
	
	left.button_released.connect(left_controller_button_released)
	right.button_released.connect(right_controller_button_released)
	
	left.button_pressed.connect(left_controller_button_pressed)
	right.button_pressed.connect(right_controller_button_pressed)
	
	left.input_float_changed.connect(left_controller_trigger_pressed)
	right.input_float_changed.connect(right_controller_trigger_pressed)
	
	world_scale = 3.2
	
	#Global.load_scene(LIST_OF_LEVELS_RESOURCE.list_of_levels[0].path_scene)

func left_controller_button_released(button_name: String):
	if button_name == "ax_button":
		pass
	if button_name == "by_button":
		pass
	if button_name == "primary_click":
		music_edit_mode = false


func left_controller_button_pressed(button_name: String):
	if button_name == "ax_button":
		if playlist_edit_mode:
			Global.gamepad_playlist_next.emit()
	if button_name == "by_button":
		if playlist_edit_mode:
			Global.gamepad_playlist_prev.emit()
	if button_name == "primary_click":
		music_edit_mode = true


func right_controller_button_released(button_name: String):
	if button_name == "ax_button":
		pass
	if button_name == "by_button":
		pass
	if button_name == "primary_click":
		playlist_edit_mode = false


func right_controller_button_pressed(button_name: String):
	if button_name == "ax_button":
		if music_edit_mode:
			Global.gamepad_music_next.emit()
	if button_name == "by_button":
		if music_edit_mode:
			Global.gamepad_music_prev.emit()
	if button_name == "primary_click":
		playlist_edit_mode = true


func left_controller_trigger_pressed(trigger_name: String, value: float):
	if trigger_name == "trigger":
		pass


func right_controller_trigger_pressed(trigger_name: String, value: float):
	if trigger_name == "trigger":
		pass
