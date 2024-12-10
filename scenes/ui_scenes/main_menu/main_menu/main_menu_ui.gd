extends Control

const hud_level_info = preload("res://scenes/levels/hub/hud_level_info.tres")
const list_of_levels_resource = preload("res://scenes/levels/list_of_levels_resource.tres")
const car_item_list_resource = preload("res://scenes/cars/car_item_list_resource.tres")

const select_button_options = preload("res://scenes/ui_scenes/main_menu/main_menu/select_button_options.tscn")

@onready var main_control = $MainControl
@onready var level_control = $LevelControl
@onready var car_control = $CarControl
@onready var loading_screen_control = $LoadingScreenControl


@onready var level_panel = $MainControl/MainStage/MainContainer/LevelPanel
@onready var car_panel = $MainControl/MainStage/MainContainer/CarPanel
@onready var tag_panel = $MainControl/MainStage/MainContainer/TagPanel

@onready var progress_bar = $LoadingScreenControl/ProgressBar
@onready var description_label = $MainControl/MainStage/VBoxContainer3/MarginContainer/MarginContainer/Panel/Label

@onready var level_grid_container = $LevelControl/GridContainer
@onready var car_grid_container = $CarControl/GridContainer


var current_level: LevelInfo
var current_level_index: int = 0

var current_car: CarItem :
	set(value):
		current_car = value
		Global.current_car = current_car

var current_car_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	level_panel.input_entered.connect(level_input_entered)
	car_panel.input_entered.connect(car_input_entered)
	Global.call_in_game_menu_changed.connect(call_in_game_menu_changed_handler)
	current_level = list_of_levels_resource.list_of_levels[0]
	print(current_level.icon_scene)
	
	current_car = car_item_list_resource.car_item_list[0]
	
	update_level_panel()
	update_car_panel()
	update_tag_panel()
	
	change_visible_scene("main_control")
	
	level_button_setup()
	car_button_setup()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_visible_scene(control_variant: String):
	match control_variant:
		"main_control":
			main_control.visible = true
			level_control.visible = false
			car_control.visible = false
			loading_screen_control.visible = false
		"level_control":
			main_control.visible = false
			level_control.visible = true
			car_control.visible = false
			loading_screen_control.visible = false
		"car_control":
			main_control.visible = false
			level_control.visible = false
			car_control.visible = true
			loading_screen_control.visible = false
		"loading_screen_control":
			main_control.visible = false
			level_control.visible = false
			car_control.visible = false
			loading_screen_control.visible = true

func update_level_panel():
	level_panel.update_icon(current_level.icon_scene)
	level_panel.update_text_description(current_level.level_name)

func update_car_panel():
	car_panel.update_icon(current_car.icon_scene)
	car_panel.update_text_description(current_car.car_name) 

func update_tag_panel():
	tag_panel.update_text_description(current_level.level_tag) 

func level_input_entered():
	description_label.text = current_level.level_description

func car_input_entered():
	description_label.text = current_car.car_description

func level_button_setup():
	for level in list_of_levels_resource.list_of_levels:
		var button = select_button_options.instantiate()
		button.button_level_info = level
		level_grid_container.add_child(button)
		button.select_button_pressed.connect(select_button_pressed_handler)

func car_button_setup():
	for car in car_item_list_resource.car_item_list:
		var button = select_button_options.instantiate()
		button.button_car_info = car
		car_grid_container.add_child(button)
		button.select_button_pressed.connect(select_button_pressed_handler)

func select_button_pressed_handler(info):
	if info is LevelInfo:
		current_level = info
		update_level_panel()
		update_tag_panel()
		change_visible_scene("main_control")
	elif info is CarItem:
		current_car = info
		update_car_panel()
		change_visible_scene("main_control")

func _on_exit_pressed():
	if !Global.in_game_menu_visible:
		Global.game_exit.emit()
	else:
		Global.load_scene(hud_level_info.path_scene, progress_bar)	

func _on_start_level_pressed():
	change_visible_scene("loading_screen_control")
	Global.load_scene(current_level.path_scene, progress_bar)

func _on_return_pressed():
	change_visible_scene("main_control")

func _on_select_level_pressed():
	change_visible_scene("level_control")

func _on_select_car_pressed():
	change_visible_scene("car_control")

func call_in_game_menu_changed_handler():
	change_visible_scene("main_control")
