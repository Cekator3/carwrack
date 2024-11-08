extends VBoxContainer
##Class for "smart" mapping the UI for control mapping
class_name ViVeGUIControlVariable

##The car controls to edit
static var control_ref:ViVeCarControls = ViVeCarControls.new():
	set(new_control):
		control_ref = new_control

##Variable this is responsible for changing
@export var var_name:StringName
##The node with the button, slider, etc.
@onready var editing_node:Control
##Text label to show value
@onready var amount:Label = $info/amount
##Value cache for sliders. This prevents the UI from lagging.
var float_cache:float
##The Variant.type of the variable
var var_type:int

#technically speaking, there is a "hole" where if you can edit a setting before 
#control_ref is ever set, it will error. Currently though, because of how everything loads, this
#should not be an active issue


func load_information() -> void:
	if not is_instance_valid(ViVeEnvironment.get_singleton().car):
		return
	
	control_ref = ViVeEnvironment.get_singleton().car.car_controls
	var_type = typeof(control_ref.get(var_name))
	var monitored_variable:Variant = control_ref.get(var_name)
	
	$"info/amount".text = str(control_ref.get(var_name))
	
	match editing_node.get_class():
		"HSlider", "VSlider":
			var slider:Slider = editing_node as Slider
			slider.value = float(monitored_variable)
		"CheckBox", "CheckButton", "Button":
			var checkbox:BaseButton = editing_node as BaseButton
			checkbox.button_pressed = bool(monitored_variable)
		"TextEdit", "LineEdit":
			##TODO: Implement text nodes
			pass
		

func _init() -> void:
	ViVeEnvironment.get_singleton().connect("car_changed", load_information)

func _ready() -> void:
	$info/text.text = var_name
	
	if has_node("value"):
		editing_node = get_node("value")
	
	if not is_instance_valid(editing_node):
		push_error("No valid value node for setting ", var_name)
		return
	
	#set up according connections depending on the GUI element type
	match editing_node.get_class():
		"HSlider", "VSlider":
			var slider:Slider = editing_node as Slider
			slider.connect(&"value_changed", _on_value_changed)
			slider.connect(&"drag_ended", _on_drag_end)
			#This ugly line just sets the value once when the parent eventually loads in (because children load first)
			ViVeEnvironment.get_singleton().connect(&"car_changed", slider.set.bind(var_name, control_ref.get.bind(var_name)), CONNECT_ONE_SHOT)
		"CheckBox", "CheckButton", "Button":
			var checkbox:BaseButton = editing_node as BaseButton
			checkbox.connect(&"toggled", _on_toggled)
		"TextEdit", "LineEdit":
			##TODO: Implement text nodes
			pass
		"OptionButton":
			var options:OptionButton = editing_node as OptionButton
			options.connect(&"item_selected", _on_item_selected)

#for checkbutton/checkbox
func _on_toggled(active:bool) -> void:
	control_ref.set(var_name, active)
	amount.text = str(active)

#for sliders
func _on_value_changed(val:float) -> void:
	float_cache = val
	amount.text = str(val)

func _on_drag_end(val_changed:bool) -> void:
	if val_changed:
		if var_type == TYPE_INT:
			control_ref.set(var_name, float_cache)
		else:
			control_ref.set(var_name, float_cache)

#for text nodes (TODO)

#for option buttons

func _on_item_selected(index:int) -> void:
	control_ref.set(var_name, index)
	amount.text = str(index)
