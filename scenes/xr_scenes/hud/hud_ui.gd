extends Control


func _process(delta):
	$FPS.text = "FPS: %s" % str(Engine.get_frames_per_second())
	$RPM.text = "RPM: %s" % str(Global.car_rpm)
	$Speed.text = "Speed: %s km/h" % str(Global.car_speed)
	$Gear.text = "Gear: %s" % str(Global.car_gear)
	
	$SteeringAngle.text = "SteeringWheel: %s" % str(Global.debug_analog_axis)
	$Throttle.text = "Throttle: %s" % str(Global.gas_trigger)
	$Brake.text = "Brake: %s" % str(Global.brake_trigger)
	
