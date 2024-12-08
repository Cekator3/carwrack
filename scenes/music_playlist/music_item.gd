extends Resource
class_name MusicItem

@export var music_audio_stream: AudioStream
@export var music_name: String
@export var music_author: String
@export_range(-10, 10) var music_volume_boost: float = 0
