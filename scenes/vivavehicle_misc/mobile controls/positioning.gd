extends TouchScreenButton

@onready var default_pos:Vector2 = position / get_parent().base_resolution
@onready var default_size:Vector2 = scale / get_parent().base_resolution

func _ready() -> void:
	position = default_pos * Vector2(DisplayServer.window_get_size_with_decorations())
	scale = default_size * Vector2(DisplayServer.window_get_size_with_decorations())


func press(state:bool) -> void:
	if state:
		Input.action_press(action)
	else:
		Input.action_release(action)
