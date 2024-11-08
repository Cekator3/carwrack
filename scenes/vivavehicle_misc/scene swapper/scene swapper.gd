extends ScrollContainer

@onready var button:Button = $container/_DEFAULT.duplicate()

const base_directory:String = "res://MISC/scene swapper/"

var literal_cache:Dictionary = {}

var loading_check_thread:Thread = Thread.new()

var packed_map_scene_path:String

var packed_map:PackedScene

var map_node:Node3D

signal threaded_map_load_done

func list_files_in_directory(path:String) -> PackedStringArray:
	
	var files:PackedStringArray = []
#	var dir = Directory.new()
	var dir:DirAccess = DirAccess.open(path)
	dir.list_dir_begin()
	
	while true:
		var file:String = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	
	dir.list_dir_end()
	
	return files

func load_and_cache(path:String) -> PackedScene:
	var loaded:PackedScene = null
	
	if path in literal_cache:
		pass
	else:
		literal_cache[path] = load(path)
	
	loaded = literal_cache[path]
	return loaded

func old_swap_map(naem:String) -> void:
	#world.get_node(current_map).queue_free()
	ViVeEnvironment.get_singleton().scene.queue_free()
	
	packed_map_scene_path = base_directory + "scenes/" + naem + "/scene.tscn"
	
	var d:Node = load_and_cache(packed_map_scene_path).instantiate()
	
	ViVeEnvironment.get_singleton().add_child(d)
	ViVeEnvironment.get_singleton().scene = d
	
	await get_tree().create_timer(0.1).timeout
	ViVeEnvironment.get_singleton().car.global_position = Vector3.ZERO
	ViVeEnvironment.get_singleton().car.global_rotation = Vector3.ZERO
	ViVeEnvironment.get_singleton().car.linear_velocity = Vector3.ZERO
	ViVeEnvironment.get_singleton().car.angular_velocity = Vector3.ZERO

func threaded_load_map(naem:StringName) -> void:
	packed_map_scene_path = base_directory + "scenes/" + naem + "/scene.tscn"
	
	connect("threaded_map_load_done", threaded_load_map_step_2, CONNECT_ONE_SHOT)
	ResourceLoader.load_threaded_request(packed_map_scene_path, "PackedScene", true, ResourceLoader.CACHE_MODE_REUSE)
	loading_check_thread.start(threaded_load_check_loading, Thread.PRIORITY_NORMAL)

func threaded_load_map_step_2() -> void:
	loading_check_thread.wait_to_finish()
	assert(packed_map != null, "Map did not load properly. Please ensure scene.tscn is present and properly loaded.")
	
	map_node = packed_map.instantiate()
	
	ViVeEnvironment.get_singleton().scene.queue_free()
	ViVeEnvironment.get_singleton().add_child(map_node)
	ViVeEnvironment.get_singleton().scene = map_node
	
	ViVeEnvironment.get_singleton().car.global_position = Vector3.ZERO
	ViVeEnvironment.get_singleton().car.global_rotation = Vector3.ZERO
	ViVeEnvironment.get_singleton().car.linear_velocity = Vector3.ZERO
	ViVeEnvironment.get_singleton().car.angular_velocity = Vector3.ZERO
	
	packed_map = null

func threaded_load_check_loading() -> void:
	var status:ResourceLoader.ThreadLoadStatus = ResourceLoader.THREAD_LOAD_IN_PROGRESS
	
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		status = ResourceLoader.load_threaded_get_status(packed_map_scene_path)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		packed_map = ResourceLoader.load_threaded_get(packed_map_scene_path)
		emit_signal.call_deferred("threaded_map_load_done")
	
	elif (status == ResourceLoader.THREAD_LOAD_FAILED) or (status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE):
		packed_map = null
		
		emit_signal.call_deferred("threaded_map_load_done")

func _ready() -> void:
	$container/_DEFAULT.queue_free()
	
	for maps:String in list_files_in_directory(base_directory + "scenes"):
		var new_button:Button = button.duplicate()
		$container.add_child(new_button)
		
		new_button.get_node("mapname").text = maps
		var img_path:String = base_directory + "scenes/" + maps + "/thumbnail.png"
		if FileAccess.file_exists(img_path):
			new_button.get_node("icon").texture = load(img_path)
		
		new_button.pressed.connect(threaded_load_map.bind(maps))
