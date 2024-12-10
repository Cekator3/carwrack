shader_type spatial;

uniform float outerRadius : hint_range(0.0, 5.0) = 1.0;
uniform float MainAlpha : hint_range(0.0, 1.0) = 1.0;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0);

uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void fragment() {
	vec2 base_uv = UV;
	
	float x = abs(UV.x - 0.5)*2.0;
	float y = abs(UV.y - 0.5)*2.0;
	float v = (sqrt((x*x*x)+(y*y*y))/outerRadius);
	
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo_tex.rgb;
	ALPHA = 1.0-clamp(v*MainAlpha, 0, 1);
	
	vec4 texture_roughness_tex = texture(texture_roughness, base_uv);
	ROUGHNESS = texture_roughness_tex.r * roughness;
	
	vec4 texture_normal_tex = texture(texture_normal, base_uv);
	NORMAL_MAP = texture_normal_tex.rgb;
	NORMAL_MAP_DEPTH = normal_scale;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
