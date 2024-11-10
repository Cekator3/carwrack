extends Node

#Scene manager and ui
var scene_manager: SceneManager 
var active_ui_layer: Control 


#Car variables 
var global_rpm: int = 0
var global_speed: int = 0
var player_in_the_car: bool = false


#Logic of change_current_scene and threaded loading
func change_current_scene(change_to_scene: PackedScene): 
	scene_manager.change_current_scene_with_ui(change_to_scene, active_ui_layer)

func load_scene(path_scene: String, progress_bar: ProgressBar = null) -> void:
	var loading_scene: PackedScene
	
	if ResourceLoader.has_cached(path_scene):
		loading_scene = ResourceLoader.load(path_scene)
	else:
		ResourceLoader.load_threaded_request(path_scene)
		
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
		
		Global.change_current_scene(loading_scene)
