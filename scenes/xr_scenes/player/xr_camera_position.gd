extends Marker3D


@export var xr_origin_3d: XROrigin3D
@export_range(0, 10) var max_position_range: float

var xr_instance_valid: bool = false


func _ready():
	if !is_instance_valid(xr_origin_3d):
		await xr_origin_3d.ready
	xr_instance_valid = true
	
	fix_camera_position()


func _process(delta):
	if xr_instance_valid:
		check_and_fix_camera_position()
	
	if Input.is_action_just_pressed("ui_accept"):
		fix_camera_position()


func fix_camera_position() -> void:
	var camera_diff: Vector3 = self.position - (xr_origin_3d.position + (-xr_origin_3d.xr_camera.position)) #XRCamera inverted
	#prints(diff_position, check_max_range_vector3(diff_position, max_position_range))
	xr_origin_3d.position.x += camera_diff.x
	xr_origin_3d.position.z += camera_diff.z


func check_and_fix_camera_position() -> void:
	var camera_diff: Vector3 = self.position - (xr_origin_3d.position + (-xr_origin_3d.xr_camera.position)) #XRCamera inverted
	#prints(camera_diff, xr_origin_3d.position + (-xr_origin_3d.xr_camera.position), check_max_range_vector3(camera_diff, max_position_range))
	
	if !check_max_range_vector3(camera_diff, max_position_range):
		xr_origin_3d.position.x += camera_diff.x
		xr_origin_3d.position.z += camera_diff.z
		pass


func check_max_range_vector3(diff: Vector3, max_range: float) -> bool:
	var diff_x: float = diff.x
	var diff_y: float = diff.y
	var diff_z: float = diff.z
	
	if check_max_range_float(diff_x, max_range) and check_max_range_float(diff_z, max_range):
		return true
	return false


func check_max_range_float(diff: float, max_range: float) -> bool:
	#prints(abs(diff), max_range, abs(diff) <= max_range)
	if abs(diff) <= max_range:
		return true
	return false
