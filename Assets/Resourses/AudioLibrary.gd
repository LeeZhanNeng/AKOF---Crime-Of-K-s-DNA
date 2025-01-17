extends Resource
class_name AudioLibrary

@export var sound_effects: Array[SFX]

func get_audio_stream(_tag: String) -> AudioStream:
	var index = -1
	if _tag:
		for sound in sound_effects:
			index += 1
			if sound.tag == _tag:
				return sound_effects[index].stream
				break
	return null
