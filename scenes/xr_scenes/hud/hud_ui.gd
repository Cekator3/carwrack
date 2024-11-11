extends Control


func _process(delta):
	$FPS.text = "FPS: %s" % str(Engine.get_frames_per_second())
	$RPM.text = "RPM: %s" % str(Global.car_rpm)
	$Speed.text = "Speed: %s km/h" % str(Global.car_speed)
