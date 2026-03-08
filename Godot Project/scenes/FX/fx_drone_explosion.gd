extends Node3D

@onready var main_explosion: GPUParticles3D = $MainExplosion
@onready var little_bits: GPUParticles3D = $LittleBits


func _ready() -> void:
	main_explosion.emitting = true
	little_bits.emitting = true
