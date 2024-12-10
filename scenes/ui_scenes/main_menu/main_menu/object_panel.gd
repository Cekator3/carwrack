extends Panel

signal input_entered
signal input_exited

@onready var icon = get_node_or_null("Icon")
@onready var label = $Label


func _ready():
	self.mouse_entered.connect(mouse_entered_handler)
	self.mouse_exited.connect(mouse_exited_handler)

func mouse_entered_handler():
	input_entered.emit()

func mouse_exited_handler():
	input_exited.emit()

func update_icon(tex: Texture):
	if icon:
		icon.texture = tex

func update_text_description(text: String):
	label.text = text
