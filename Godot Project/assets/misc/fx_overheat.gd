extends Node3D
class_name OverheatFX

@onready var smoke_particles: GPUParticles3D = $SmokeParticles


func emit_particles():
	smoke_particles.emitting = true
	
func stop_emitting():
	smoke_particles.emitting = false
