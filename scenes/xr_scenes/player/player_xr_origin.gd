extends XROrigin3D

@onready var xr_camera := get_node_or_null("XRCamera3D")

@onready var left: XRController3D = $Left
@onready var right: XRController3D = $Right


func _ready():
	Global.player_xr_origin = self
	
	left.button_released.connect(left_controller_button_released)
	
	left.button_pressed.connect(left_controller_button_pressed)
	right.button_pressed.connect(right_controller_button_pressed)
	
	left.input_float_changed.connect(left_controller_trigger_pressed)
	right.input_float_changed.connect(right_controller_trigger_pressed)
	
	world_scale = 3.1


func left_controller_button_released(button_name: String):
	if button_name == "ax_button":
		Global.handbrake_button = false


func left_controller_button_pressed(button_name: String):
	if button_name == "ax_button":
		Global.handbrake_button = true


func right_controller_button_pressed(button_name: String):
	pass


func left_controller_trigger_pressed(trigger_name: String, value: float):
	if trigger_name == "trigger":
		Global.brake_trigger = value


func right_controller_trigger_pressed(trigger_name: String, value: float):
	if trigger_name == "trigger":
		Global.gas_trigger = value


func _process(delta):
	pass
