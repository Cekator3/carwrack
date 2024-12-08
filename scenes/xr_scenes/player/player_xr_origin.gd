extends XROrigin3D

@onready var xr_camera := get_node_or_null("XRCamera3D")
@onready var xr_car := get_parent()

@onready var left: XRController3D = $Left
@onready var right: XRController3D = $Right

var xr_car_position: Vector3 = Vector3.ZERO
var restart_button: bool = false
var restart_button_cooldown: bool = false
var restart_process: float = 0

var music_edit_mode: bool = false
var playlist_edit_mode: bool = false

func _ready():
	Global.player_xr_origin = self
	
	left.button_released.connect(left_controller_button_released)
	right.button_released.connect(right_controller_button_released)
	
	left.button_pressed.connect(left_controller_button_pressed)
	right.button_pressed.connect(right_controller_button_pressed)
	
	left.input_float_changed.connect(left_controller_trigger_pressed)
	right.input_float_changed.connect(right_controller_trigger_pressed)
	
	world_scale = 3.1
	
	xr_car_position = xr_car.position


func left_controller_button_released(button_name: String):
	if button_name == "ax_button":
		Global.handbrake_button = false
	if button_name == "by_button":
		restart_button = false
	if button_name == "primary_click":
		music_edit_mode = false


func left_controller_button_pressed(button_name: String):
	if button_name == "ax_button":
		if playlist_edit_mode:
			Global.gamepad_playlist_next.emit()
		else:
			Global.handbrake_button = true
	if button_name == "by_button":
		if playlist_edit_mode:
			Global.gamepad_playlist_prev.emit()
		else:
			restart_button = true
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
		Global.brake_trigger = value


func right_controller_trigger_pressed(trigger_name: String, value: float):
	if trigger_name == "trigger":
		Global.gas_trigger = value


func restart_car():
	xr_car.position = xr_car_position
	xr_car.rotation = Vector3.ZERO


func _process(delta):
	if (restart_button or Input.is_action_pressed("restart")) and !restart_button_cooldown: 
		restart_process += 1.75 * delta
		
		if playlist_edit_mode:
			restart_button = false
		
		if restart_process > 3:
			restart_process = 3
			restart_car()
			restart_button_cooldown = true
	else:
		restart_process -= 1.75 * delta
		if restart_process < 0:
			restart_process = 0
			restart_button_cooldown = false
	
	Global.respawn_process_value = restart_process
