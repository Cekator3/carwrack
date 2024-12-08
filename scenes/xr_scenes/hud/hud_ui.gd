extends Control


@onready var fps = $Debug/MarginContainer/FPS
@onready var rpm = $InGameHud/MarginContainer/Control/HBoxContainer/RPM
@onready var speed = $InGameHud/MarginContainer/Control/HBoxContainer/Speed
@onready var gear = $InGameHud/MarginContainer/Control/Gear

@onready var throttle_progress_bar = $InGameHud/MarginContainer/Control/ThrottleMarginContainer/ThrottleProgressBar
@onready var brake_progress_bar = $InGameHud/MarginContainer/Control/BrakeMarginContainer/BrakeProgressBar

@onready var attention_progress_bar = $AttentionHud/MarginContainer/VBoxContainer/AttentionProgressBar
@onready var attention_message = $AttentionHud/MarginContainer/VBoxContainer/AttentionMessage
var default_attention_message: String

func _ready():
	default_attention_message = attention_message.text

func _process(delta):
	if Input.is_action_just_pressed("debug"):
		$Debug.visible = !$Debug.visible
	
	fps = $Debug/MarginContainer/FPS 
	fps.text = "FPS: %s" % str(Engine.get_frames_per_second())
	
	
	rpm.text = "RPM: %s" % str(Global.car_rpm)
	speed.text = "%s km/h" % str(Global.car_speed)
	gear.text = "%s" % correct_gear(Global.car_gear)
	
	throttle_progress_bar.value = Global.gas_trigger
	brake_progress_bar.value = Global.brake_trigger
	
	attention_progress_bar.value = Global.respawn_process_value
	
	
	if !Global.car_is_overturned: 
		attention_progress_bar.modulate = Color(1, 1, 1) if attention_progress_bar.value > 0 else Color(1, 1, 1, 0)
		attention_message.modulate = Color(1, 1, 1) if attention_progress_bar.value > 0 else Color(1, 1, 1, 0)
	else:
		attention_progress_bar.modulate = Color(1, 1, 1)
		attention_message.modulate = Color(1, 1, 1)
	
	
	if attention_progress_bar.value > 0: 
		attention_message.text = "Respawning..."
	else: 
		attention_message.text = default_attention_message


func correct_gear(gear: int):
	var result: String = ""
	
	match gear:
		-1: 
			result = "R"
		0: 
			result = "N"
		_:
			result = str(gear)
	
	return result
