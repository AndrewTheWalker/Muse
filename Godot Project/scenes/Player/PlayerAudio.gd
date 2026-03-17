extends Node

@onready var kor_death_hit: AudioStreamPlayer = $KorDeathHit
@onready var kor_hit: AudioStreamPlayer = $KorHit
@onready var kor_jump: AudioStreamPlayer = $KorJump
@onready var kor_land: AudioStreamPlayer = $KorLand
@onready var kor_overheat: AudioStreamPlayer = $KorOverheat
@onready var kor_respawn: AudioStreamPlayer = $KorRespawn
@onready var kor_roll: AudioStreamPlayer = $KorRoll
@onready var kor_shoot: AudioStreamPlayer = $KorShoot
@onready var kor_step: AudioStreamPlayer = $KorStep


func play_sound(sound_name : String):
	match sound_name:
		"death_hit" :
			kor_death_hit.play()
		"hit" :
			kor_hit.play()
		"jump" :
			kor_jump.play()
		"land" :
			kor_land.play()
		"overheat" :
			kor_overheat.play()
		"roll" :
			kor_roll.play()
		"shoot" :
			kor_shoot.play()
		"step" :
			kor_step.play()

func stop_playing(sound_name : String):
	match sound_name:
		"death_hit" :
			kor_death_hit.stop()
		"hit" :
			kor_hit.stop()
		"jump" :
			kor_jump.stop()
		"land" :
			kor_land.stop()
		"overheat" :
			kor_overheat.stop()
		"roll" :
			kor_roll.stop()
		"shoot" :
			kor_shoot.stop()
		"step" :
			kor_step.stop()
