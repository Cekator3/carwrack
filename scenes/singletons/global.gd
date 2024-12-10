extends Node


#Level func/variables
signal player_instantiated

signal player_pressed_centered
signal car_respawned

signal screen_turned_black
signal screen_turned_transparent

signal music_changed
signal gamepad_music_prev
signal gamepad_music_next
signal gamepad_playlist_prev
signal gamepad_playlist_next

signal call_in_game_menu_changed

signal game_exit

var current_car: CarItem

var current_music_in_playlist: MusicItem : 
	set(value):
		if current_music_in_playlist != value:
			current_music_in_playlist = value
			music_changed.emit()

var scene_is_hub: bool = true
var current_playlist_name: String = ""

var in_game_menu_visible: bool = false

var map_level_failed: bool = false
var current_map_can_be_completed: bool = false

var player_xr_origin: XROrigin3D

var respawn_process_value: float = 0
var car_is_overturned: bool = false

func fail_map():
	map_level_failed = true

func restart_map():
	map_level_failed = false


#Scene manager and ui
var scene_manager: SceneManager 
var active_ui_layer: Control 

var debug_analog_axis: float = 0
var debug_gas_strength: float = 0
var debug_brake_strength: float = 0

#Car variables 
var car_rpm: int = 0
var car_speed: int = 0
var car_gear: int = 0
var player_in_the_car: bool = false


#Car control 
signal transmission_reversed(is_reversed: bool)

var min_max_steering_angle: float

var gas_trigger: float = 0
var brake_trigger: float = 0
var physical_steering_angle: float = 0
var handbrake_button: bool = false
var is_reverse: bool = false :
	set(value):
		if is_reverse != value:
			is_reverse = value
			transmission_reversed.emit(value)
			prints("is_reverse", value)


#Create custom tween and property logic
func create_tween_custom(tween, ease: Tween.EaseType, trans: Tween.TransitionType):
	if tween != null:
		while tween.get_reference_count() > 0:
			tween.unreference()
		tween.kill()
	
	var return_tween: Tween 
	if is_instance_valid(active_ui_layer):
		return_tween = create_tween().bind_node(active_ui_layer)
	else: 
		return_tween = create_tween().bind_node(self)
	
	return_tween.set_ease(ease)
	return_tween.set_trans(trans)
	return return_tween

func tween_p_property_custom(tween: Tween, object: Object, node_path: String, from: Variant = null, to: Variant = null, duration: float = 0.1):
	await tween.parallel().tween_property(object,\
		node_path, to, duration).from(from).finished
	tween.stop()

func tween_property_custom(tween: Tween, object: Object, node_path: String, from: Variant = null, to: Variant = null, duration: float = 0.1):
	await tween.tween_property(object,\
		node_path, to, duration).from(from).finished
	tween.kill()


#Logic of change_current_scene and threaded loading
func change_current_scene(change_to_scene: PackedScene): 
	scene_manager.change_current_scene_with_ui(change_to_scene, active_ui_layer)

func load_scene(path_scene: String, progress_bar: ProgressBar = null) -> void:
	var loading_scene: PackedScene
	
	if ResourceLoader.has_cached(path_scene):
		loading_scene = ResourceLoader.load(path_scene)
	else:
		ResourceLoader.load_threaded_request(path_scene, "", true)
		
		while true:
			var progress := []
			
			var res := ResourceLoader.load_threaded_get_status(path_scene, progress)
			if res != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				break
			
			if is_instance_valid(progress_bar):
				if progress_bar.value < progress[0]:
					progress_bar.value = progress[0]
			
			await get_tree().create_timer(0.2).timeout
		
		if is_instance_valid(progress_bar):
			progress_bar.value = 1
		
		loading_scene = ResourceLoader.load_threaded_get(path_scene)
		
		change_current_scene(loading_scene)
