extends Node3D
class_name CarSpawner

var car = load(Global.current_car.path_scene)

func _ready():
	add_child(car.instantiate())
