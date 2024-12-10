extends Node3D

@export var speed_interpolate_angle: float = 20
@export var speed_interpolate_position: float = 20

var player_ref : XROrigin3D
var player_camera_ref : XRCamera3D

var initialized: bool = false

func _ready():
	self.visible = true
	
	Global.car_respawned.connect(fix_position_and_rotation)
	
	if !is_instance_valid(Global.player_xr_origin):
		prints("await", "Global.player_xr_origin")
		await Global.player_instantiated
	
	player_ref = Global.player_xr_origin
	player_camera_ref = player_ref.xr_camera

func _physics_process(delta):
	if initialized: 
		self.global_rotation.y = lerp_angle(self.global_rotation.y, player_camera_ref.global_rotation.y, delta * speed_interpolate_angle) 
		self.global_rotation.x = lerp_angle(self.global_rotation.x, player_camera_ref.global_rotation.x, delta * speed_interpolate_angle)
		self.global_rotation.z = lerp_angle(self.global_rotation.z, player_camera_ref.global_rotation.z, delta * (speed_interpolate_angle * 0.775))
		
		self.global_position = lerp(self.global_position, player_camera_ref.global_position, delta * speed_interpolate_position)

func fix_position_and_rotation():
	initialized = true
	if is_instance_valid(player_camera_ref):
		self.global_rotation = player_camera_ref.global_rotation
		self.global_position = player_camera_ref.global_position
	else:
		player_ref = Global.player_xr_origin
		player_camera_ref = player_ref.xr_camera
		self.global_rotation = player_camera_ref.global_rotation
		self.global_position = player_camera_ref.global_position

func _process(delta):
	if !initialized: 
		fix_position_and_rotation()
