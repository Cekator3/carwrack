extends Node3D


@onready var interactable_hinge = $PhysicalSteer/InteractableHinge


func _ready():
	pass # Replace with function body.



func _process(delta):
	Global.physical_steering_angle = interactable_hinge.hinge_position
	print(Global.physical_steering_angle)
