@tool
class_name XRToolsMovementDirect
extends XRToolsMovementProvider


## XR Tools Movement Provider for Direct Movement
##
## This script provides direct movement for the player. This script works
## with the [XRToolsPlayerBody] attached to the players [XROrigin3D].
##
## The player may have multiple [XRToolsMovementDirect] nodes attached to
## different controllers to provide different types of direct movement.


@export var dead_zone : float = 0.2


## Movement provider order
@export var order : int = 10

## Movement speed
@export var max_speed : float = 3.0
@export var muliplier_speed : float = 1.5
@export var muliplier_сurve : Curve

## If true, the player can strafe
@export var strafe : bool = false

## Input action for movement direction
@export var input_action : String = "primary"


# Controller node
@onready var _controller := XRHelpers.get_xr_controller(self)


# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "XRToolsMovementDirect" or super(name)


# Perform jump movement
func physics_movement(_delta: float, player_body: XRToolsPlayerBody, _disabled: bool):
	# Skip if the controller isn't active
	if !_controller.get_is_active():
		return
	
	var vec2_controller := _controller.get_vector2(input_action)
	
	if abs(vec2_controller.x) < dead_zone:
		vec2_controller.x = 0
	if abs(vec2_controller.y) < dead_zone:
		vec2_controller.y = 0
	
#	print("после: ", vec2_controller)
	
	# Apply forwards/backwards ground control
	player_body.ground_control_velocity.y += vec2_controller.y * max_speed * muliplier_сurve.sample(abs(vec2_controller.y))

	# Apply left/right ground control
	if strafe:
		player_body.ground_control_velocity.x += vec2_controller.x * max_speed * muliplier_сurve.sample(abs(vec2_controller.x))

	# Clamp ground control
	var length := player_body.ground_control_velocity.length()
	if length > max_speed:
		player_body.ground_control_velocity *= max_speed / length


# This method verifies the movement provider has a valid configuration.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super()

	# Check the controller node
	if !XRHelpers.get_xr_controller(self):
		warnings.append("This node must be within a branch of an XRController3D node")

	# Return warnings
	return warnings


## Find the left [XRToolsMovementDirect] node.
##
## This function searches from the specified node for the left controller
## [XRToolsMovementDirect] assuming the node is a sibling of the [XROrigin3D].
static func find_left(node : Node) -> XRToolsMovementDirect:
	return XRTools.find_xr_child(
		XRHelpers.get_left_controller(node),
		"*",
		"XRToolsMovementDirect") as XRToolsMovementDirect


## Find the right [XRToolsMovementDirect] node.
##
## This function searches from the specified node for the right controller
## [XRToolsMovementDirect] assuming the node is a sibling of the [XROrigin3D].
static func find_right(node : Node) -> XRToolsMovementDirect:
	return XRTools.find_xr_child(
		XRHelpers.get_right_controller(node),
		"*",
		"XRToolsMovementDirect") as XRToolsMovementDirect
