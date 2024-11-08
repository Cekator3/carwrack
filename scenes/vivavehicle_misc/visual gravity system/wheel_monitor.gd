extends Polygon2D
class_name ViVeDebugWheelMonitor

@onready var slippage:Polygon2D = $"slippage"
@onready var background:Polygon2D = $"background"

var pos:Vector2
var setting:ViVeTyreSettings
var node:ViVeWheel

func update(parent_size:Vector2, vgs_scale:float) -> void:
	if not is_instance_valid(node):
		return
	position = parent_size * 0.5
	position += ((pos * (64.0 / vgs_scale)) / 9.806)
	
	slippage.scale.y = maxf((node.slip_percent_pre) * 0.8, 0.0)
	
	rotation_degrees = - node.rotation_degrees.y
	
	self_modulate = Color.WHITE
	
	if slippage.scale.y > 0.8:
		slippage.scale.y = 0.8
		if absf(node.wv * node.w_size) > node.velocity.length():
			self_modulate = Color.RED
