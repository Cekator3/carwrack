extends Resource
class_name CarItem

## Car name
@export var car_name: String = "Example"

## Level description
@export_multiline var car_description: String = ""

## Level PackedScene
@export var path_scene: String

## Level PackedScene
@export var icon_scene: Texture = preload("res://scenes/levels/level_intro/level_intro_icon.png")
