extends Node3D

@export var speed_sky_interpolation = 20

@onready var world_environment = $WorldEnvironment

var spectrum: AudioEffectSpectrumAnalyzerInstance
var sky: Sky 


const LIST_OF_LEVELS_RESOURCE = preload("res://scenes/levels/list_of_levels_resource.tres")

func _ready():
	Setting.world_environment = world_environment.environment
	
	spectrum = AudioServer.get_bus_effect_instance(1, 0)
	
	world_environment.environment.fog_aerial_perspective = 0.91
	
	world_environment.environment.sky = Setting.sky_variation["hub"]
	sky = world_environment.environment.sky
	
	world_environment.environment.ambient_light_source = 1
	
	Global.scene_is_hub = true

func _process(delta):
	var avarage_energy_multiplier = get_music_spectrum_height() * 0.66 + 0.33
	
	sky.sky_material.ground_bottom_color.v = lerpf(sky.sky_material.ground_bottom_color.v, avarage_energy_multiplier, delta * speed_sky_interpolation)
	
	if Input.is_action_just_pressed("ui_accept"):
		Global.load_scene(LIST_OF_LEVELS_RESOURCE.list_of_levels[0].path_scene)

func get_music_spectrum_height():
	var freq_mono_range: float = spectrum.get_magnitude_for_frequency_range(100, 200).length()
	var energy = clamp((60 + linear_to_db(freq_mono_range)) / 60, 0, 1)
	return energy
