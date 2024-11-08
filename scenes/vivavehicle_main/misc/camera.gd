extends Marker3D

var default_cam_pos:Vector3
var can_drag:bool = false
var just_resetted:bool = false

@export var mobile_controls:NodePath = NodePath()
@export var car:ViVeCar = null

@onready var camera:Camera3D = $"orbit/Camera"
@onready var orbit:Marker3D = $"orbit"
@onready var car_cam_center:Node3D = null
@onready var mobile_controls_node:Node2D

var drag_velocity:Vector2 = Vector2.ZERO
var last_pos:Vector2 = Vector2.ZERO
var x_drag_unlocked:bool = false
var y_drag_unlocked:bool = false

var resetdel:int = 0
var default_zoom:float

func _ready() -> void:
	default_cam_pos = camera.position
	default_zoom = default_cam_pos.z
	car = weakref(ViVeEnvironment.get_singleton().car).get_ref()
	if mobile_controls:
		mobile_controls_node = get_node(mobile_controls)
	ViVeEnvironment.get_singleton().connect("car_changed", set_car)

func set_car() -> void:
	car = weakref(ViVeEnvironment.get_singleton().car).get_ref()
	if is_instance_valid(car):
		if car.has_node(^"CAMERA_CENTRE"):
			car_cam_center = car.get_node(^"CAMERA_CENTRE")
		else:
			car_cam_center = null

func _process(_delta:float) -> void:
	if is_instance_valid(car):
		if is_instance_valid(car_cam_center):
			look_at(car_cam_center.global_position)
			position = car_cam_center.global_position
		else:
			look_at(car.position)
			position = car.position
		translate_object_local(Vector3(0, 0, 14.5))
		
		orbit.global_position = car.global_position
		camera.position = default_cam_pos - orbit.position

func _physics_process(_delta:float) -> void:
	if Input.is_action_pressed("zoom_out"):
		default_cam_pos.z += 0.05
	elif Input.is_action_pressed("zoom_in"):
		default_cam_pos.z -= 0.05
	
	if Input.is_action_pressed("CAM_orbit_left"):
		orbit.rotation_degrees.y += Input.get_action_strength("CAM_orbit_left")
	elif Input.is_action_pressed("CAM_orbit_right"):
		orbit.rotation_degrees.y -= Input.get_action_strength("CAM_orbit_right")
	
	if Input.is_action_pressed("CAM_orbit_reset"):
		orbit.rotation_degrees.y = 0.0
		default_cam_pos.z = default_zoom
	
	resetdel -= 1

func _input(event:InputEvent) -> void:
	if is_instance_valid(mobile_controls_node) and mobile_controls_node.visible:
		can_drag = true
		for i:TouchScreenButton in mobile_controls_node.get_children():
			if i.is_pressed():
				can_drag = false
		if event is InputEventScreenTouch:
			if can_drag:
				last_pos = event.position
				if not event.is_pressed():
					if resetdel > 0:
						orbit.rotation_degrees.y = 0.0
						default_cam_pos.z = default_zoom
						just_resetted = true
					resetdel = 15
		else:
			just_resetted = false
		if event is InputEventScreenDrag:
			if can_drag and not just_resetted:
				drag_velocity.x = event.position.x - last_pos.x
				drag_velocity.y = event.position.y - last_pos.y
				last_pos = event.position
				
				if absf(drag_velocity.y) > 5.0:
					y_drag_unlocked = true
				if absf(drag_velocity.x) > 5.0:
					x_drag_unlocked = true
				
				if y_drag_unlocked:
					default_cam_pos.z += drag_velocity.y / 200.0
				if x_drag_unlocked:
					orbit.rotation_degrees.y -= drag_velocity.x / 2.0
				resetdel = -1
		if event.is_action_released("gas_mouse"):
			x_drag_unlocked = false
			y_drag_unlocked = false
