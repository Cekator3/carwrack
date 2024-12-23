extends WorldEnvironment
##The singleton representing the base of the SceneTree in a VitaVehicle instance.
class_name ViVeEnvironment

##The default Environment.
const default_sky:Environment = preload("res://default_env.tres")

##The ViVeEnvironment singleton
##NOTE:Using this is considered unsafe in comparison to calling [method ViVeEnvironment.get_singleton]
static var singleton:ViVeEnvironment = null
##The current environment.
var current_sky:Environment = environment
##Debug mode for the car. This enables certain things that are, good for debugging or configuring cars,
##but otherwise would be needlessly taking performance away from the simulation.
var Debug_Mode:bool = true
##An internal multiplier for changing the effective speed of the simulation.
var clock_mult:float = 1.0

##The currently active player car.
##NOTE: Could be changed in the future to accomodate multiple player cars, but right now acts singularly.
#@onready var car:ViVeCar = $"car":
	#set(new):
		#car = new
		#emit_signal("car_changed")

##The currently loaded play scene.
@onready var scene:Node3D = $"Scene":
	set(new):
		scene = new
		emit_signal("scene_changed")

#@onready var sun:DirectionalLight3D = $"morning_sun"

##Emitted when the car, or something about it, is changed.
##NOTE: Could be changed in the future to accomodate multiple player cars, but right now acts singularly.
signal car_changed
##Emitted when the play scene changes.
signal scene_changed

##Emiited when the Environment changes
signal env_changed

func _init() -> void:
	singleton = self
	print(singleton)

func _ready() -> void:
	Setting.world_environment = self.environment
	self.environment.sky = Setting.sky_variation["default"]
	
	environment.fog_aerial_perspective = 0.91
	
	environment.ambient_light_source = 0
	
	Global.scene_is_hub = false

##Safer version of just using the singleton variable, even tho the variable is 
##what's currently used in the codebase :P
static func get_singleton() -> ViVeEnvironment:
	if singleton != null:
		return singleton
	else:
		return ViVeEnvironment.new()

func switch_sky() -> void:
	return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_mode"):
		if Debug_Mode:
			Debug_Mode = false
			#car.Debug_Mode = false
		else:
			Debug_Mode = true
			#car.Debug_Mode = true
