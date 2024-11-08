extends ScrollContainer

var car:ViVeCar

var viewport_size:Vector2i

const default_sky:Environment = preload("res://default_env.tres")

func _ready() -> void:
	viewport_size.x = ProjectSettings.get("display/window/size/viewport_width")
	viewport_size.y = ProjectSettings.get("display/window/size/viewport_height")
	for i:CheckBox in $container.get_children():
		i.button_pressed = misc_graphics_settings.get(i.name)
	

func _on__fullscreen_toggled(toggled_on:bool) -> void:
	if not toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(viewport_size)
		DisplayServer.window_set_position(DisplayServer.screen_get_size() / 2 - viewport_size / 2)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_tyre_smoke_toggled(toggled_on: bool) -> void:
	misc_graphics_settings.smoke = toggled_on

func _on_vsync_toggled(toggled_on:bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_fxaa_toggled(toggled_on:bool) -> void:
	misc_graphics_settings.fxaa = toggled_on
	if toggled_on:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	else:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED

func _on_shadows_toggled(toggled_on:bool) -> void:
	misc_graphics_settings.shadows = toggled_on
	ViVeEnvironment.get_singleton().sun.shadow_enabled = toggled_on

func _on_reflections_toggled(toggled_on:bool) -> void:
	misc_graphics_settings.reflections = toggled_on

func _on_use_procedural_sky_toggled(toggled_on:bool) -> void:
	misc_graphics_settings.use_procedural_sky = toggled_on
	ViVeEnvironment.get_singleton().switch_sky()

