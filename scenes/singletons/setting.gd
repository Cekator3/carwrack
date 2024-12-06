extends Node


@onready var main_viewport: Viewport = get_tree().get_root().get_viewport()

var world_environment: Environment


var global_language: String = "ru"
var LANGUAGE_TYPE = {
	"en" =\
		null,
	"ru" =\
		{
			"Off" = "Выкл",
			"Very Low" = "Очень низкий",
			"Low" = "Низкий", 
			"Medium" = "Средний", 
			"High" = "Высокий", 
			"Very High" = "Очень высокий", 
			"Native" = "Нативное", 
		}
}

func _ready():
	world_environment = load("res://default_env.tres") if world_environment == null else world_environment

# SSAO configuration 
var SSAO_QUALITY_TYPE = {
	"Off" = -1,
	"Low" = RenderingServer.ENV_SSAO_QUALITY_VERY_LOW,
	"Medium" = RenderingServer.ENV_SSAO_QUALITY_LOW,
	"High" = RenderingServer.ENV_SSAO_QUALITY_MEDIUM
}

var ssao_quality: int = SSAO_QUALITY_TYPE["Off"] :
	set(value):
		ssao_quality = value
		if ssao_quality == -1:
			world_environment.ssao_enabled = false
			return 
		world_environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(ssao_quality, true, 0.5, 2, 50, 300)
	get:
		return ssao_quality

# SSIL configuration
var SSIL_QUALITY_TYPE = {
	"Off" = -1,
	"Low" = RenderingServer.ENV_SSIL_QUALITY_VERY_LOW,
	"Medium" = RenderingServer.ENV_SSIL_QUALITY_LOW,
	"High" = RenderingServer.ENV_SSIL_QUALITY_MEDIUM
}

var ssil_quality: int = SSIL_QUALITY_TYPE["Off"] :
	set(value):
		ssil_quality = value
		if ssil_quality == -1:
			world_environment.ssil_enabled = false
			return 
		world_environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(ssil_quality, true, 0.5, 3, 50, 300)
	get:
		return ssil_quality

# Glow configuration
var GLOW_QUALITY_TYPE = {
	"Off" = -1,
	"Medium" = 0,
	"High" = 1
}

var glow_quality: int = GLOW_QUALITY_TYPE["Off"] :
	set(value):
		glow_quality = value
		if glow_quality == -1:
			world_environment.glow_enabled = false
			return 
		world_environment.glow_enabled = true
		RenderingServer.environment_glow_set_use_bicubic_upscale(bool(glow_quality))
	get:
		return glow_quality

# Volume fog configuration
var VOLUME_FOG_QUALITY_TYPE = {
	"Off" = false,
	"Medium" = true
}

var volume_fog_quality: bool = VOLUME_FOG_QUALITY_TYPE["Off"] :
	set(value):
		volume_fog_quality = value
		if volume_fog_quality == false:
			world_environment.volumetric_fog_enabled = false
			world_environment.fog_enabled = true
			return 
		world_environment.volumetric_fog_enabled = true
		world_environment.fog_enabled = false
	get:
		return volume_fog_quality

# Shadow resolution quality configuration (DirectionalLight3D, OmniLight3D и SpotLight3D) 
var SHADOW_RESOLUTION_QUALITY_TYPE = {
	"Off" = -1,
	"Very Low" = 512,
	"Low" = 1024,
	"Medium" = 2048,
	"High" = 4096,
	"Very High" = 8192
}

var shadow_resolution_quality: int = SHADOW_RESOLUTION_QUALITY_TYPE["Medium"] :
	set(value):
		shadow_resolution_quality = value
		 
		# Get DirectionalLight3D from "shadow_directional_light" group or
		# OmniLight3D/SpotLight3D from "shadow_light" group
		var directional_light_list = get_tree().get_nodes_in_group("shadow_directional_light") 
		var position_light_list = get_tree().get_nodes_in_group("shadow_light")
		
		
		if shadow_resolution_quality == -1:
			set_enable_light_shadows(directional_light_list, false)
			set_enable_light_shadows(position_light_list, false)
			return 
		
		# DirectionalLight3D --configuration start
		set_enable_light_shadows(directional_light_list, true)
		RenderingServer.directional_shadow_atlas_set_size(shadow_resolution_quality, true)
		# DirectionalLight3D --configuration end
		
		# OmniLight3D and SpotLight3D --configuration start
		set_enable_light_shadows(position_light_list, true)
		main_viewport.set_positional_shadow_atlas_size(shadow_resolution_quality)
		# OmniLight3D and SpotLight3D --configuration end
	get:
		return shadow_resolution_quality

func set_enable_light_shadows(array_light, is_enabled) -> void:
	for light in array_light:
		light.shadow_enabled = is_enabled

# Shadow filter quality configuration (DirectionalLight3D. OmniLight3D и SpotLight3D) 
var SHADOW_BLUR_QUALITY_TYPE = {
	"Off" = RenderingServer.SHADOW_QUALITY_HARD,
	"Very Low" = RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW,
	"Low" = RenderingServer.SHADOW_QUALITY_SOFT_LOW,
	"Medium" = RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM,
	"High" = RenderingServer.SHADOW_QUALITY_SOFT_HIGH
}

var shadow_blur_quality: RenderingServer.ShadowQuality = SHADOW_BLUR_QUALITY_TYPE["Medium"] :
	set(value):
		shadow_blur_quality = value
		RenderingServer.directional_soft_shadow_filter_set_quality(shadow_blur_quality)
		RenderingServer.positional_soft_shadow_filter_set_quality(shadow_blur_quality)
	get:
		return shadow_blur_quality

# FXAA Configuration 
var use_fxaa: bool = false : 
	set(value):
		use_fxaa = value
		main_viewport.set_screen_space_aa(int(use_fxaa))
	get:
		return use_fxaa

# MSAA Configuration 
var MSAA_QUALITY_TYPE = {
	"Off" = Viewport.MSAA_DISABLED,
	"2x" = Viewport.MSAA_2X,
	"4x" = Viewport.MSAA_4X,
	"8x" = Viewport.MSAA_8X
}

var msaa_quality: Viewport.MSAA = MSAA_QUALITY_TYPE["Off"] : 
	set(value):
		msaa_quality = value
		main_viewport.msaa_3d = msaa_quality
	get:
		return msaa_quality

# FSR 1.0 Configuration
var FSR_QUALITY_TYPE = {
	"50%" = 0.5,
	"59%" = 0.59,
	"67%" = 0.67,
	"77%" = 0.77,
	"85%" = 0.85,
	"Native" = 1
}

var fsr_quality = FSR_QUALITY_TYPE["Native"] : 
	set(value):
		main_viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR 
		fsr_quality = value
		main_viewport.scaling_3d_scale = fsr_quality
	get:
		return fsr_quality
