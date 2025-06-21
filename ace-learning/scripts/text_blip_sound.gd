extends AudioStreamPlayer

const sounds := {
	"male": preload("res://assets/sound/sfx-blipmale.wav"),
	"female": preload("res://assets/sound/sfx-blipfemale.wav"),
	"default": preload("res://assets/sound/sfx-blipmale.wav")
}

func play_sound(gender: String):
	stream = sounds[gender]
	play()
