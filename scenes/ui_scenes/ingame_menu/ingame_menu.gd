extends Node3D


@export var speed_interpolate_angle: float = 20
@export var speed_interpolate_position: float = 20
@export var snap_float: float = 2

@onready var main_menu = $MainMenuUis/MainMenu/Screen
@onready var setting_menu = $MainMenuUis/SettingMenu/Screen

var player_ref : XROrigin3D
var player_camera_ref : XRCamera3D

var initialized: bool = false

func _ready():
	self.visible = true
	Global.in_game_menu_visible = false
	
	Global.car_respawned.connect(fix_position_and_rotation)
	Global.call_in_game_menu_changed.connect(call_in_game_menu_changed_handler)
	if !is_instance_valid(Global.player_xr_origin):
		prints("await", "Global.player_xr_origin")
		await Global.player_instantiated
	
	main_menu.transparency = 1
	setting_menu.transparency = 1
	
	player_ref = Global.player_xr_origin
	player_camera_ref = player_ref.xr_camera

func _physics_process(delta):
	if initialized: 
		if check_global_rotation(global_rotation, player_camera_ref.global_rotation):
			self.global_rotation.y = lerp_angle(self.global_rotation.y, player_camera_ref.global_rotation.y, delta * speed_interpolate_angle) 
			#self.global_rotation.x = lerp_angle(self.global_rotation.x, player_camera_ref.global_rotation.x, delta * speed_interpolate_angle)
			#self.global_rotation.z = lerp_angle(self.global_rotation.z, player_camera_ref.global_rotation.z, delta * (speed_interpolate_angle * 0.775))
		
		self.global_position = lerp(self.global_position, player_camera_ref.global_position, delta * speed_interpolate_position)

func check_global_rotation(global_rot: Vector3, camera_global_rot: Vector3):
	var local_rotation: Vector3 = abs(self.global_rotation - player_camera_ref.global_rotation)
	if local_rotation.x > snap_float or local_rotation.y > snap_float or local_rotation.z > snap_float:
		return true
	return false


func fix_position_and_rotation():
	initialized = true
	if is_instance_valid(player_camera_ref):
		self.global_rotation = player_camera_ref.global_rotation
		self.global_position = player_camera_ref.global_position
	else:
		player_ref = Global.player_xr_origin
		player_camera_ref = player_ref.xr_camera
		self.global_rotation = player_camera_ref.global_rotation
		self.global_position = player_camera_ref.global_position

func _process(delta):
	if !initialized: 
		fix_position_and_rotation()

func visible_animation():
	var tween_trans_main = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	Global.tween_p_property_custom(tween_trans_main, main_menu, "transparency", 1, 0, 0.25)
	var tween_trans_setting = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	await Global.tween_property_custom(tween_trans_setting, setting_menu, "transparency", 1, 0, 0.25)

func trans_animation():
	var tween_trans_main = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	Global.tween_p_property_custom(tween_trans_main, main_menu, "transparency", 0, 1, 0.25)
	var tween_trans_setting = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	await Global.tween_property_custom(tween_trans_setting, setting_menu, "transparency", 0, 1, 0.25)

func call_in_game_menu_changed_handler():
	if Global.in_game_menu_visible:
		visible_animation()
		fix_position_and_rotation()
	else:
		trans_animation()
