extends Resource
class_name LevelInfo

## Level name
@export var level_name: String = "Example"

## Level description
@export_multiline var level_description: String = ""

@export_multiline var level_tag: String = ""

## Level PackedScene
@export var path_scene: String

## Level PackedScene
@export var icon_scene: Texture = preload("res://scenes/levels/level_intro/level_intro_icon.png")


# Checking level information for validity
func check_info_validation() -> bool:
	if path_scene != "":
		if FileAccess.file_exists(path_scene):
			return true
	return false
