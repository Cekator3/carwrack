shader_type canvas_item;

uniform float multiplier = 1;

void fragment() {
	vec2 base_uv = UV;
	float x = abs(UV.x) * multiplier;
	COLOR.a = x;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
