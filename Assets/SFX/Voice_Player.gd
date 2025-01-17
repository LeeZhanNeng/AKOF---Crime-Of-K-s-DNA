extends AudioStreamPlayer2D

func play_voice(_voice: String) -> void:
	stream = load(_voice)
	self.play()
