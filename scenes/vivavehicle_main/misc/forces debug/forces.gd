extends MeshInstance3D

@export var Scale:float = 0.5

@onready var wheel_parent:ViVeWheel = null
@onready var compress:MeshInstance3D = $"compress"
@onready var longi:MeshInstance3D = $"longi"
@onready var lateral:MeshInstance3D = $"lateral"

func _physics_process(_delta:float) -> void:
	if not is_instance_valid(wheel_parent):
		wheel_parent = get_parent() #ViVeWheel
	visible = wheel_parent.car.Debug_Mode
	
	rotation = wheel_parent.velo_1.rotation
	position = wheel_parent.anim.position
	
	position.y -= wheel_parent.w_size
	
	if visible:
		compress.visible = wheel_parent.is_colliding()
		longi.visible = wheel_parent.is_colliding()
		lateral.visible = wheel_parent.is_colliding()
		
		#compress.scale = Vector3(0.02, wheel_parent.directional_force.y * (Scale / 1.0), 0.02)
		compress.scale.y = wheel_parent.directional_force.y * (Scale / 1.0)
		compress.position.y = compress.scale.y / 2.0
		#longi.scale = Vector3(0.02, 0.02, wheel_parent.directional_force.z * (Scale / 1.0))
		longi.scale.z = wheel_parent.directional_force.z * (Scale / 1.0)
		longi.position.z = longi.scale.z / 2.0
		#lateral.scale = Vector3(wheel_parent.directional_force.x * (Scale / 1.0), 0.02, 0.02)
		lateral.scale.x = wheel_parent.directional_force.x * (Scale / 1.0)
		lateral.position.x = lateral.scale.x / 2.0
