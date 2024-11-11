extends Node3D


@export var hinge_min_max_angle: float = 180

@onready var interactable_hinge = $PhysicalSteer/InteractableHinge


func _ready():
	interactable_hinge.hinge_limit_max = hinge_min_max_angle
	interactable_hinge.hinge_limit_min = -hinge_min_max_angle
	Global.min_max_steering_angle = hinge_min_max_angle



func _process(delta):
	Global.physical_steering_angle = interactable_hinge.hinge_position
	#print(Global.physical_steering_angle)
