extends Control

class_name ViVeInEngineTorqueGraph

@export_enum("ft⋅lb", "nm", "kg/m") var Torque_Unit:int = 1
@export_enum("hp", "bhp", "ps", "kW") var Power_Unit:int = 0

#torque normal state
@export var TorqueNormal:ViVeCarTorque = ViVeCarTorque.new()

@export var TorqueVVT:ViVeCarTorque = ViVeCarTorque.new("VVT")
#torque @export variable valve timing triggered

@export var draw_scale:float = 0.005
@export var Generation_Range:float = 7000.0
@export var Draw_RPM:float = 800.0

@onready var torque:Line2D = $"torque"
@onready var torque_peak:Polygon2D = $"torque/peak"
@onready var power:Line2D = $"power"
@onready var power_peak:Polygon2D = $"power/peak"

var peak_torque:float = 0.0
var peak_torque_rpm:float = 0.0

var peak_horsepower:float 
var peak_horsepower_rpm:float

var car:ViVeCar = ViVeCar.new()

#This keeps getting re-called somewhere when it shouldn't be, when swapping cars
func _ready() -> void:
	ViVeEnvironment.get_singleton().connect("car_changed", draw_graph)
	connect("resized", draw_graph) #This is inefficient but I didn't want to make a function to convert the points

func draw_graph() -> void:
	car = ViVeEnvironment.get_singleton().car
	if not is_instance_valid(car):
		return
	
	Generation_Range = float(int(car.RPMLimit) + 1000.0)
	
	Draw_RPM = car.IdleRPM
	calculate()
	draw_scale = 1.0 / maxf(peak_torque, peak_horsepower)
	calculate()

func calculate() -> void:
	peak_horsepower = 0.0
	peak_horsepower_rpm = 0.0
	peak_torque = 0.0
	peak_torque_rpm = 0.0
	torque.clear_points()
	power.clear_points()
	var skip:int = 0
	for current_rpm:int in range(Generation_Range):
		if current_rpm > Draw_RPM:
			var current_torque:float = car.multivariate(current_rpm)
			var current_horsepower:float = (current_rpm / 5252.0) * current_torque
			
			if Torque_Unit == 1:
				current_torque *= 1.3558179483
			elif Torque_Unit == 2:
				current_torque *= 0.138255
			
			match Power_Unit:
				1:
					current_horsepower *= 0.986
				2:
					current_horsepower *= 1.01387
				3:
					current_horsepower *= 0.7457
			
			var torque_position:Vector2 = Vector2((current_rpm / Generation_Range) * size.x, size.y - (current_torque * size.y) * draw_scale)
			var horsepower_position:Vector2 = Vector2((current_rpm / Generation_Range) * size.x, size.y - (current_horsepower * size.y) * draw_scale)
			
			if current_horsepower > peak_horsepower:
				peak_horsepower = current_horsepower
				peak_horsepower_rpm = current_rpm
				power_peak.position = horsepower_position
			
			if current_torque > peak_torque:
				peak_torque = current_torque
				peak_torque_rpm = current_rpm
				torque_peak.position = torque_position
			
			skip -= 1
			if skip <= 0:
				torque.add_point(torque_position)
				power.add_point(horsepower_position)
				skip = 100
