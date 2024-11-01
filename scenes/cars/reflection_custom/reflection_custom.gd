@tool
extends ReflectionProbe

@export_range(0.0, 5.0) var reflection_intensity: float = 1.0 :
	set(value):
		if reflection_intensity != value:
			reflection_intensity = value
			self.intensity = reflection_intensity
