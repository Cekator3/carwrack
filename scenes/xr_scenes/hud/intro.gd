extends Node3D


@onready var intro_animation := $IntroAnimation

@onready var main_menu_uis = $MainMenuUis
@onready var main_menu_screen = $MainMenuUis/MainMenu/Screen
@onready var setting_menu_screen = $MainMenuUis/SettingMenu/Screen

@onready var screen_intro = $ScreenIntro
@onready var game_name = $GameName


func _ready():
	Global.game_exit.connect(game_exit_handler)
	
	main_menu_screen.transparency = 1
	setting_menu_screen.transparency = 1
	game_name.transparency = 1
	
	intro_animation.play(&"intro")
	run_animation()

func run_animation():
	await get_tree().create_timer(3).timeout
	
	var tween_trans_screen = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	Global.tween_p_property_custom(tween_trans_screen, screen_intro, "transparency", 0, 1, 2)
	var tween_position_screen = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	await Global.tween_property_custom(tween_position_screen, screen_intro, "position", screen_intro.position, Vector3(0, 6, -10.5), 2)
	
	var tween_trans_main = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	Global.tween_p_property_custom(tween_trans_main, main_menu_screen, "transparency", 1, 0, 1)
	var tween_trans_setting = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	await Global.tween_property_custom(tween_trans_setting, setting_menu_screen, "transparency", 1, 0, 1)

func exit_animation():
	var tween_trans_main = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	Global.tween_p_property_custom(tween_trans_main, main_menu_screen, "transparency", 0, 1, 1)
	var tween_trans_setting = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	await Global.tween_property_custom(tween_trans_setting, setting_menu_screen, "transparency", 0, 1, 1)
	
	var tween_trans_screen = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	Global.tween_p_property_custom(tween_trans_screen, screen_intro, "transparency", 1, 0, 2)
	var tween_position_screen = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	await Global.tween_property_custom(tween_position_screen, screen_intro, "position", screen_intro.position, Vector3(0, 6, -11), 2)

func game_exit_handler():
	await exit_animation()
	
	get_tree().quit()
