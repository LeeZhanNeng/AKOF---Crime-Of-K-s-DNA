extends AudioStreamPlayer

@export var audio_library: AudioLibrary
@export var custom_max_polyphonic: int = 32

func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = custom_max_polyphonic
	
func play_sfx(_tag: String) -> int:
	if _tag:
		var audio_stream = audio_library.get_audio_stream(_tag)
		
		if !playing:
			self.play()
		
		var stream_playback := self.get_stream_playback()
		var id = stream_playback.play_stream(audio_stream)
		return id
	return 0

func stop_sfx(_id: int) -> int:
	if _id:
		if !playing:
			self.play()
		var stream_playback := self.get_stream_playback()
		stream_playback.stop_stream(_id)
	return 0
