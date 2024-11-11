extends Node3D

@export var speed_interpolate_angle: float = 20
@export var speed_interpolate_position: float = 20

var player_ref : XROrigin3D
var player_camera_ref : XRCamera3D

func _ready():
	self.visible = true
	
	if !is_instance_valid(Global.player_xr_origin):
		await Global.player_instantiated
	
	player_ref = Global.player_xr_origin
	player_camera_ref = player_ref.xr_camera

func _physics_process(delta):
	self.global_rotation.y = lerp_angle(self.rotation.y, player_camera_ref.global_rotation.y, delta * speed_interpolate_angle) 
	self.global_rotation.x = lerp_angle(self.rotation.x, player_camera_ref.global_rotation.x, delta * speed_interpolate_angle) 
	self.global_position = lerp(self.global_position, player_camera_ref.global_position, delta * speed_interpolate_position)
