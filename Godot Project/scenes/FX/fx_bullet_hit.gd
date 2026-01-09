extends Node3D
class_name HitFX

# someday I will have to properly make an FX class
@onready var explode_particle: GPUParticles3D = $ExplodeParticle
@onready var hit_timer: Timer = $HitTimer

func _ready() -> void:
	explode_particle.emitting = true
	await hit_timer.timeout
	queue_free()
