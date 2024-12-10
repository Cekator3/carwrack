extends AudioStreamPlayer

@export var resource_music_playlists: MusicPlaylist
@onready var default_volume_db: float = self.volume_db

var playlist: MusicPlaylistItem : 
	set(value):
		playlist = value
		Global.current_playlist_name = playlist.playlist_name
		set_new_music_to_stream(playlist.music_items_in_playlist[0])
		current_playlist_index = resource_music_playlists.music_playlist_items.find(playlist)
var current_playlist_index: int

var current_music: MusicItem : 
	set(value):
		current_music = value
		Global.current_music_in_playlist = current_music
		stream = current_music.music_audio_stream
		volume_db = default_volume_db + current_music.music_volume_boost
		current_music_index = playlist.music_items_in_playlist.find(current_music)
var current_music_index: int

func _ready():
	Global.gamepad_music_prev.connect(prev_music_handler)
	Global.gamepad_music_next.connect(next_music_handler)
	
	Global.gamepad_playlist_prev.connect(prev_playlist_handler)
	Global.gamepad_playlist_next.connect(next_playlist_handler)
	
	self.finished.connect(next_music_handler)
	
	playlist = resource_music_playlists.music_playlist_items[2]
	set_new_music_to_stream(playlist.music_items_in_playlist[0])


func _process(delta):
	if Input.is_action_just_pressed("next_music"):
		next_music_handler()
	if Input.is_action_just_pressed("prev_music"):
		prev_music_handler()
	if Input.is_action_just_pressed("next_playlist"):
		next_playlist_handler()
	if Input.is_action_just_pressed("prev_playlist"):
		prev_playlist_handler()

# music
func next_music_handler():
	if current_music_index < playlist.music_items_in_playlist.size() - 1:
		set_new_music_to_stream(playlist.music_items_in_playlist[current_music_index + 1])
	else: 
		set_new_music_to_stream(playlist.music_items_in_playlist[0])

func prev_music_handler():
	if current_music_index > 0:
		set_new_music_to_stream(playlist.music_items_in_playlist[current_music_index - 1])
	else: 
		set_new_music_to_stream(playlist.music_items_in_playlist[playlist.music_items_in_playlist.size() - 1])

func set_new_music_to_stream(music_item: MusicItem):
	self.stop()
	current_music = music_item
	self.play()

# playlist
func next_playlist_handler():
	if current_playlist_index < resource_music_playlists.music_playlist_items.size() - 1:
		set_new_playlist_to_stream(resource_music_playlists.music_playlist_items[current_playlist_index + 1])
	else: 
		set_new_playlist_to_stream(resource_music_playlists.music_playlist_items[0])

func prev_playlist_handler():
	if current_playlist_index > 0:
		set_new_playlist_to_stream(resource_music_playlists.music_playlist_items[current_playlist_index - 1])
	else: 
		set_new_playlist_to_stream(resource_music_playlists.music_playlist_items[resource_music_playlists.music_playlist_items.size() - 1])

func set_new_playlist_to_stream(playlist_item: MusicPlaylistItem):
	playlist = playlist_item
