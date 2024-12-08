extends Control

@onready var music_play_now = $MarginContainer/Panel/HBoxContainer/MusicPlayNow
@onready var aspect_ratio_container = $MarginContainer/Panel/HBoxContainer/AspectRatioContainer

@onready var music_name = $MarginContainer/Panel/HBoxContainer/MusicPlayNow/Name
@onready var music_author = $MarginContainer/Panel/HBoxContainer/MusicPlayNow/Author
@onready var type_playlist = $MarginContainer/Panel/TypePlaylist


var tween_hide_is_running: bool = false
var time_start_count: bool = false

var spectrum: AudioEffectSpectrumAnalyzerInstance

func request_show():
	time_start_count = false
	tween_hide_is_running = false
	
	var current_music = Global.current_music_in_playlist
	var current_playlist_name = Global.current_playlist_name
	
	if !is_instance_valid(current_music):
		music_name.text = "Empty"
		music_author.text = "Empty"
	else:
		music_name.text = current_music.music_name
		music_author.text = current_music.music_author
	
	type_playlist.text = current_playlist_name
	
	var tween_playlist_modulation: Tween = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	Global.tween_p_property_custom(tween_playlist_modulation, self, "modulate", Color(1, 1, 1, 0),  Color(1, 1, 1), 1)
	
	var tween_play_container_ratio: Tween = Global.create_tween_custom(null, Tween.EASE_OUT, Tween.TRANS_QUART)
	await Global.tween_p_property_custom(tween_play_container_ratio, music_play_now, "size_flags_stretch_ratio", 0, 1, 1)
	
	time_start_count = true

func get_music_spectrum_height():
	var freq_mono_range: float = spectrum.get_magnitude_for_frequency_range(20, 2000).length()
	var energy = clamp((60 + linear_to_db(freq_mono_range)) / 60, 0, 1)
	return energy

func _init():
	self.modulate = Color(1, 1, 1, 0)

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(1, 0)
	Global.music_changed.connect(request_show)

func _process(delta):
	if Input.is_action_just_pressed("debug"):
		request_show()
	
	aspect_ratio_container.ratio = 0.33 + get_music_spectrum_height()/3 * 2


var local_current_time: float = 0
var local_expected_time: float = 3
func _physics_process(delta):
	if time_start_count:
		local_current_time += delta
		if local_current_time > local_expected_time:
			local_current_time = 0
			time_start_count = false
			tween_hide_is_running = true
	else:
		local_current_time = 0
	
	if tween_hide_is_running:
		self.modulate.a -= delta * 0.75
		if self.modulate.a <= 0:
			self.modulate.a = 0
			tween_hide_is_running = false
