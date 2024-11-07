extends ViVeTransmission
##A manual, sequential transmission 
class_name ViVeTransmissionManual

##Final Drive Ratio refers to the last set of gears that connect a vehicle's engine to the driving axle.
@export var FinalDriveRatio:float = 4.250
##A set of gears a vehicle's transmission has, in order from first to last. [br]
##A gear ratio is the ratio of the number of rotations of a driver gear  to the number of rotations of a driven gear .
@export var GearRatios:Array[float] = [ 3.250, 1.894, 1.259, 0.937, 0.771 ]
##The gear ratio of the reverse gear.
@export var ReverseRatio:float = 3.153
##Similar to FinalDriveRatio, but this should not relate to any real-life data. You may keep the value as it is.
@export var RatioMult:float = 9.5
##The amount of stress put into the transmission (as in accelerating or decelerating) to restrict clutchless gear shifting.
@export var StressFactor:float = 1.0
##A space between the teeth of all gears to perform clutchless gear shifts. Higher values means more noise. Compensate with StressFactor.
@export var GearGap:float = 60.0



@export_group("Shifting")

@export var ActionNameShiftUp:StringName

@export var ActionNameShiftDown:StringName

@export var ClutchOutRPM:float

@export var ShiftDelay:float

@export var InputDelay:float

@export var AssistUpShiftRPM:float

@export var AssistDownShiftRPM:float

var clutch_in:bool = false

var clutch_pedal:float

var gear:int

var actual_gear:int

var gear_stress:float

var shift_up_pressed:bool

var shift_down_pressed:bool

var shift_assist_delay:float

var shift_assist_step:int

var speed_influence:float

func transmission_callback(rpm:float) -> float:
	shift_up_pressed = Input.is_action_just_pressed(ActionNameShiftUp)
	shift_down_pressed = Input.is_action_just_pressed(ActionNameShiftDown)
	
	clutch_pedal = car.car_controls.get_clutch(not(car.clutch_pressed and not clutch_in))
	
	clutch_engage_percent = 1.0 - clutch_pedal
	
	if gear > 0:
		car.drive_axle_rpm = GearRatios[gear - 1] * FinalDriveRatio * RatioMult
	elif gear == ViVeTransmission.REVERSE:
		car.drive_axle_rpm = ReverseRatio * FinalDriveRatio * RatioMult
	
	if car.car_controls.ShiftingAssistance == 0:
		if shift_up_pressed:
			shift_up_pressed = false
			if gear < GearRatios.size():
				if gear_stress < GearGap:
					actual_gear += 1
		if shift_down_pressed:
			shift_down_pressed = false
			if gear > ViVeTransmission.REVERSE:
				if gear_stress < GearGap:
					actual_gear -= 1
	
	elif car.car_controls.ShiftingAssistance == 1:
		if rpm < ClutchOutRPM:
			clutch_pedal = minf(pow((ClutchOutRPM - rpm) / (ClutchOutRPM - car.IdleRPM), 2.0), 1.0)
		else:
			if not car.gas_restricted and not car.rev_match:
				clutch_in = false
		
		if car.shift_up_pressed:
			car.shift_up_pressed = false
			if gear < GearRatios.size():
				if rpm < ClutchOutRPM:
					actual_gear += 1
				else:
					if actual_gear < 1:
						actual_gear += 1
						if rpm > ClutchOutRPM:
							clutch_in = false
					else:
						if shift_assist_delay > 0:
							actual_gear += 1
						shift_assist_delay = ShiftDelay / 2.0
						shift_assist_step = -4
						
						clutch_in = true
						car.gas_restricted = true
		
		elif shift_down_pressed:
			shift_down_pressed = false
			if gear > ViVeTransmission.REVERSE:
				if rpm < ClutchOutRPM:
					actual_gear -= 1
				else:
					if actual_gear == 0 or actual_gear == 1:
						actual_gear -= 1
						clutch_in = false
					else:
						if shift_assist_delay > 0:
							actual_gear -= 1
						shift_assist_delay = ShiftDelay / 2.0
						shift_assist_step = -2
						
						clutch_in = true
						car.rev_match = true
						car.gas_restricted = false
	
	elif car.car_controls.ShiftingAssistance == 2:
		var assist_shift_speed:float = (AssistUpShiftRPM / car.drive_axle_rpm) * speed_influence
		var assist_down_shift_speed:float = (AssistDownShiftRPM / absf((GearRatios[gear - 2] * FinalDriveRatio) * RatioMult)) * speed_influence
		if gear == 0:
			if car.gas_pressed:
				shift_assist_delay -= 1
				if shift_assist_delay < 0:
					actual_gear = 1
			elif car.brake_pressed:
				shift_assist_delay -= 1
				if shift_assist_delay < 0:
					actual_gear = ViVeTransmission.REVERSE
			else:
				shift_assist_delay = 60
		elif car.linear_velocity.length() < 5:
			if not car.gas_pressed and gear == 1 or not car.brake_pressed and gear == ViVeTransmission.REVERSE:
				shift_assist_delay = 60
				actual_gear = 0
		if shift_assist_step == 0:
			if rpm < ClutchOutRPM:
				clutch_pedal = minf(pow((ClutchOutRPM - rpm) / (ClutchOutRPM - car.IdleRPM), 2.0), 1.0)
			else:
				clutch_in = false
			if gear != ViVeTransmission.REVERSE:
				if gear < GearRatios.size() and car.linear_velocity.length() > assist_shift_speed:
					shift_assist_delay = ShiftDelay / 2.0
					shift_assist_step = -4
					
					clutch_in = true
					car.gas_restricted = true
				if gear > 1 and car.linear_velocity.length() < assist_down_shift_speed:
					shift_assist_delay = ShiftDelay / 2.0
					shift_assist_step = -2
					
					clutch_in = true
					car.gas_restricted = false
					car.rev_match = true
	
	if shift_assist_step == -4 and shift_assist_delay < 0:
		shift_assist_delay = ShiftDelay / 2.0
		if gear < GearRatios.size():
			actual_gear += 1
		shift_assist_step = -3
	
	elif shift_assist_step == -3 and shift_assist_delay < 0:
		if rpm > ClutchOutRPM:
			clutch_in = false
		if shift_assist_delay < - InputDelay:
			shift_assist_step = 0
			car.gas_restricted = false
	
	elif shift_assist_step == -2 and shift_assist_delay < 0:
		shift_assist_step = 0
		if gear > ViVeTransmission.REVERSE:
			actual_gear -= 1
		if rpm > ClutchOutRPM:
			clutch_in = false
		car.gas_restricted = false
		car.rev_match = false
	
	gear = actual_gear
	
	return rpm
