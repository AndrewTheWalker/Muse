extends Node3D

@onready var converging_particles: GPUParticles3D = $ConvergingParticles
@onready var growing_glow: GPUParticles3D = $GrowingGlow

var spawn_pos : Vector3

func _ready() -> void:
	global_position = spawn_pos
	converging_particles.emitting = true
	growing_glow.emitting = true
	await growing_glow.finished
	queue_free()
