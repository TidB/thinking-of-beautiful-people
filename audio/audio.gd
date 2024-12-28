extends Node

func _ready():
	play_bg()

func play_bg():
	$Bg.play()

func play_explosion():
	$Explosion.play()

func play_siren():
	$Siren.play()

func stop_siren():
	$Siren.stop()
