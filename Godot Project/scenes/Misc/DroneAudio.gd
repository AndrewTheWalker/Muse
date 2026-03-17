extends Node

@onready var enemy_charge_up: AudioStreamPlayer3D = $EnemyChargeUp
@onready var enemy_death_hit: AudioStreamPlayer3D = $EnemyDeathHit
@onready var enemy_detected: AudioStreamPlayer3D = $EnemyDetected
@onready var enemy_explode: AudioStreamPlayer3D = $EnemyExplode
@onready var kor_shoot: AudioStreamPlayer3D = $KorShoot
@onready var bullet_hit_1: AudioStreamPlayer3D = $BulletHit1


func play_sound(sound_name : String):
	match sound_name:
		"charge" :
			enemy_charge_up.play()
		"hit" :
			bullet_hit_1.play()
		"death_hit" :
			enemy_death_hit.play()
		"explode" :
			enemy_explode.play()
		"shoot" :
			kor_shoot.play()
		"detect" :
			enemy_detected.play()
