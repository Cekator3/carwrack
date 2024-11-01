extends Node

@onready var current_scene = $CurrentScene


func _ready():
	Setting.world_environment = $WorldEnvironment.environment


func _process(delta):
	pass
