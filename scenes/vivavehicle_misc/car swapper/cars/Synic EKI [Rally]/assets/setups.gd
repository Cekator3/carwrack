extends Node

@export_group("Gravel Tyres")
@export var tire_gravel:ViVeTyreSettings 
@export var compound_gravel:TyreCompoundSettings
@export var axle_gravel:ViVeWheelAxle
@export var suspension_gravel_front:ViVeWheelSuspension
@export var suspension_gravel_rear:ViVeWheelSuspension

@export_group("Tarmac Tyres")
@export var tire_tarmac:ViVeTyreSettings
@export var compound_tarmac:TyreCompoundSettings
@export var axle_tarmac:ViVeWheelAxle
@export var suspension_tarmac_front:ViVeWheelSuspension
@export var suspension_tarmac_rear:ViVeWheelSuspension

@onready var car_parent:ViVeCar = weakref(get_parent()).get_ref()


func _configure_tyres() -> void:
	#$setup2.release_focus()
	for i:ViVeWheel in car_parent.all_wheels:
		i.get_node(^"animation/camber/wheel/wheel 1").visible = false
		i.get_node(^"animation/camber/wheel/wheel 2").visible = false
		i.TyreSettings = tire_tarmac
		i.CompoundSettings = compound_tarmac
		i.AxleSettings = axle_tarmac
		if i.name.begins_with("f"):
			i.Suspension = suspension_tarmac_front
			i.Camber = 0.0
			i.W_PowerBias = 0.5
		elif i.name.begins_with("r"):
			i.Suspension = suspension_tarmac_rear
			i.Camber = -1.0
			i.W_PowerBias = 1.0

func _ready():
	_configure_tyres()
