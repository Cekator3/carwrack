extends Control
##A class representing the root of the in-game debug panel.
class_name ViVeDebug

##The debug panel singleton
static var singleton:ViVeDebug = null

var changed_graph_size:Vector2 = Vector2.ZERO
var car_rpm:StringName 
var car_front_dist:StringName
var car_rear_dist:StringName
var car_gear:StringName
var car_turbo_psi:StringName

@onready var car_node:ViVeCar
@onready var tacho:ViVeTachometer = $"tacho"
@onready var tacho_gear:Label = $tacho/gear
@onready var tacho_rpm:Label = $tacho/rpm
@onready var power_graph:ViVeInEngineTorqueGraph = $power_graph
@onready var vgs:ViVeVGS = $vgs

@onready var fps:Label = $"container/fps"
@onready var weight_dist:Label = $"container/weight_dist"

func _ready() -> void:
	if not ViVeEnvironment.get_singleton().is_connected("ready", setup):
		ViVeEnvironment.get_singleton().connect("ready", setup)
	if not ViVeEnvironment.get_singleton().is_connected("car_changed", update_car):
		ViVeEnvironment.get_singleton().connect("car_changed", update_car)
	singleton = self

func update_car() -> void:
	car_node = weakref(ViVeEnvironment.get_singleton().car).get_ref()
	
	if is_instance_valid(car_node):
		car_rpm = car_node.car_name + &"/" + car_node.perf_rpm
		car_turbo_psi = car_node.car_name + &"/" + car_node.perf_turbo_psi
		car_front_dist = car_node.car_name + &"/" + car_node.perf_front_dist
		car_rear_dist = car_node.car_name + &"/" + car_node.perf_rear_dist
		car_gear = car_node.car_name + &"/" + car_node.perf_gear
	
	var horsepower_unit:String
	match power_graph.Power_Unit:
		1:
			horsepower_unit = "bhp"
		2:
			horsepower_unit = "ps"
		3:
			horsepower_unit = "kW"
		_:
			horsepower_unit = "hp"
	
	$hp.text = "Power: %s%s @ %s RPM" % [str( int(power_graph.peak_horsepower * 10.0) / 10.0 ), horsepower_unit, str(int(power_graph.peak_horsepower_rpm * 10.0) / 10.0)]
	
	var torque_unit:String = "ft⋅lb"
	if power_graph.Torque_Unit == 1:
		torque_unit = "nm"
	elif power_graph.Torque_Unit == 2:
		torque_unit = "kg/m"
	$tq.text = "Torque: %s%s @ %s RPM" % [str(int(power_graph.peak_torque * 10.0) / 10.0 ), torque_unit, str(int(power_graph.peak_torque_rpm * 10.0) / 10.0)]


#This is signal-ified due to being "too early" when done in _ready()
func setup() -> void:
	update_car()
	vgs.clear()
	for d:ViVeWheel in car_node.all_wheels:
		vgs.append_wheel(d)
	
	#sync the power graph
	power_graph.draw_graph()


func _process(delta:float) -> void:
	if car_node.Debug_Mode:
		#This gives a more precise FPS at the cost of calculation
		fps.text = "fps: " + str(1.0 / delta)
	else:
		#This gives performs slightly better but gives a less precise FPS
		fps.text = "fps: " + str(Performance.get_monitor(Performance.TIME_FPS))
	
	$sw.rotation_degrees = car_node.effective_steer * 380.0
	$sw_desired.rotation_degrees = car_node.steer_from_input * 380.0
	if car_node.Debug_Mode:
		weight_dist.text = "weight distribution: F%f/R%f" % [Performance.get_custom_monitor(car_front_dist) * 100, Performance.get_custom_monitor(car_rear_dist) * 100]
	else:
		weight_dist.text = "[ enable Debug_Mode or press F to\nfetch weight distribution ]"
	
	$"fix engine".visible = car_node.rpm < car_node.DeadRPM
	
	$throttle.bar_scale = car_node.gas_pedal
	$brake.bar_scale = car_node.brake_pedal
	$handbrake.bar_scale = car_node.handbrake_pull
	$clutch.bar_scale = car_node.clutch_pedal
	
	var car_speed_kmph:float = car_node.linear_velocity.length() * 1.10130592
	$tacho/speedk.text = "KM/PH: " +str(int(car_speed_kmph))
	$tacho/speedm.text = "MPH: " +str(int(car_speed_kmph / 1.609))
	
	var car_current_rpm:float = Performance.get_custom_monitor(car_rpm)
	
	$power_graph/rpm.size.y = power_graph.size.y
	$power_graph/redline.size.y = power_graph.size.y
	$power_graph/rpm.position.x = (car_current_rpm / power_graph.Generation_Range) * power_graph.size.x - 1.0
	$power_graph/redline.position.x = (car_node.RPMLimit / power_graph.Generation_Range) * power_graph.size.x - 1.0
	
	#$g.text = "Gs:\nx%s,\ny%s,\nz%s" % [str(int(car_node.gforce.x * 100.0) / 100.0), str(int(car_node.gforce.y * 100.0) / 100.0), str(int(car_node.gforce.z * 100.0) / 100.0)]
	$g.text = "Gs:\nx%s,\ny%s,\nz%s" % [str(int(car_node.gforce.x)), str(int(car_node.gforce.y)), str(int(car_node.gforce.z))]
	
	tacho.currentpsi = Performance.get_custom_monitor(car_turbo_psi)
	tacho.currentrpm = car_current_rpm
	tacho_rpm.text = str(int(car_current_rpm))
	
	if car_current_rpm < 0:
		tacho_rpm.self_modulate = Color.RED
	else:
		tacho_rpm.self_modulate = Color.WHITE
	
	var current_gear:int = Performance.get_custom_monitor(car_gear)
	
	if current_gear == 0:
		tacho_gear.text = "N"
	elif current_gear == ViVeTransmission.REVERSE:
		tacho_gear.text = "R"
	else:
		if car_node.TransmissionType == 1 or car_node.TransmissionType == 2:
			tacho_gear.text = "D"
		else:
			tacho_gear.text = str(current_gear)


func _old_process(delta:float) -> void:
	if not is_instance_valid(car_node):
		return
	
	if car_node.Debug_Mode:
		#This gives a more precise FPS at the cost of calculation
		fps.text = "fps: " + str(1.0 / delta)
	else:
		#This performs slightly better but gives a less precise FPS
		fps.text = "fps: " + str(Performance.get_monitor(Performance.TIME_FPS))
	
	$sw.rotation_degrees = car_node.effective_steer * 380.0
	$sw_desired.rotation_degrees = car_node.steer_from_input * 380.0
	if car_node.Debug_Mode:
		weight_dist.text = "weight distribution: F%f/R%f" % [car_node.front_weight_distribution * 100, car_node.rear_weight_distribution * 100]
	else:
		weight_dist.text = "[ enable Debug_Mode or press F to\nfetch weight distribution ]"
	
	if changed_graph_size != power_graph.size:
		changed_graph_size = power_graph.size
		power_graph.draw_graph()
	
	$"fix engine".visible = car_node.rpm < car_node.DeadRPM
	
	$throttle.bar_scale = car_node.gas_pedal
	$brake.bar_scale = car_node.brake_pedal
	$handbrake.bar_scale = car_node.handbrake_pull
	$clutch.bar_scale = car_node.clutch_pedal
	
	var car_speed_kmph:float = car_node.linear_velocity.length() * 1.10130592
	$tacho/speedk.text = "KM/PH: " +str(int(car_speed_kmph))
	$tacho/speedm.text = "MPH: " +str(int(car_speed_kmph / 1.609))
	
	$power_graph/rpm.position.x = (car_node.rpm / power_graph.Generation_Range) * power_graph.size.x - 1.0
	$power_graph/redline.position.x = (car_node.RPMLimit / power_graph.Generation_Range) * power_graph.size.x - 1.0
	
	#$g.text = "Gs:\nx%s,\ny%s,\nz%s" % [str(int(car_node.gforce.x * 100.0) / 100.0), str(int(car_node.gforce.y * 100.0) / 100.0), str(int(car_node.gforce.z * 100.0) / 100.0)]
	$g.text = "Gs:\nx%s,\ny%s,\nz%s" % [str(int(car_node.gforce.x)), str(int(car_node.gforce.y)), str(int(car_node.gforce.z))]
	
	tacho.currentpsi = car_node.turbo_psi * (car_node.TurboAmount)
	tacho.currentrpm = car_node.rpm
	tacho_rpm.text = str(int(car_node.rpm))
	
	if car_node.rpm < 0:
		tacho_rpm.self_modulate = Color.RED
	else:
		tacho_rpm.self_modulate = Color.WHITE
	
	if car_node.gear == 0:
		tacho_gear.text = "N"
	elif car_node.gear == ViVeTransmission.REVERSE:
		tacho_gear.text = "R"
	#elif car_node.Transmission.get_current_gear() == -2:
	#	tacho_gear.text = "D"
	else:
		if car_node.TransmissionType == 1 or car_node.TransmissionType == 2:
			tacho_gear.text = "D"
		else:
			tacho_gear.text = str(car_node.gear)

func _physics_process(_delta:float) -> void:
	if not is_instance_valid(car_node):
		return
	vgs.gforce -= (vgs.gforce - Vector2(car_node.gforce.x, car_node.gforce.z)) * 0.5
	
	var tacho_label:Label = $tacho/abs
	tacho_label.visible = car_node.abs_pump > 0 and car_node.brake_pedal > 0.1
	tacho_label = $tacho/tcs
	tacho_label.visible = car_node.tcs_flash
	tacho_label = $tacho/esp
	tacho_label.visible = car_node.esp_flash

##Restarts the car's engine. Needed if the RPM dips to low and it stalls.
func engine_restart() -> void:
	if is_instance_valid(car_node):
		car_node.fix_engine_stall()
