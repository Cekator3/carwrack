extends Node
class_name SceneManager


@onready var current_scene = $CurrentScene

func _ready():
	Global.scene_manager = self

func change_current_scene_with_ui(change_to_scene: PackedScene, ui_layer: Control):
	#Close visibility for ui layer and wait signal
	ui_layer.increased_visibility()
	await Signal(ui_layer, "change_screen_increased")
	
	#When signal was emit, instantiate scene from change_to_scene PackedScene
	var scene_instance = change_to_scene.instantiate()
	
	#Get current scene and queue free it
	var current_scene_child := current_scene.get_child(0)
	current_scene_child.queue_free()
	
	#Check old current scene for validity. If instance is valid wait until it's free
	if is_instance_valid(current_scene_child):
		await current_scene.get_child(0).tree_exited
	
	#Add new scene_instance as a child of current_scene
	current_scene.add_child(scene_instance)
