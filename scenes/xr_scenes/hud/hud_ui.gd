extends Control


func _process(delta):
	$FPS.text = "FPS: %s" % str(Engine.get_frames_per_second())
	$RPM.text = "RPM: %s" % str(Global.car_rpm)
	$Speed.text = "Speed: %s km/h" % str(Global.car_speed)
	
	$AnalogAxis.text = "AnalogAxis: %s" % str(Global.debug_analog_axis)
	$SteerAxisAmount.text = "SteerAxisAmount: %s" % str(Global.debug_steer_axis_amount)
