extends Button

signal select_button_pressed(info)

@onready var icon_left = $Icon

var button_level_info: LevelInfo
var button_car_info: CarItem

func _ready():
	if is_instance_valid(button_level_info):
		icon_left.texture = button_level_info.icon_scene
		self.text = button_level_info.level_name
	elif is_instance_valid(button_car_info):
		icon_left.texture = button_car_info.icon_scene
		self.text = button_car_info.car_name


func _on_button_pressed():
	if is_instance_valid(button_level_info):
		select_button_pressed.emit(button_level_info)
	elif is_instance_valid(button_car_info):
		select_button_pressed.emit(button_car_info)
