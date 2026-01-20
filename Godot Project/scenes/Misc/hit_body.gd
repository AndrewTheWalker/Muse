extends StaticBody3D
class_name HitBody

@onready var hitbody_owner : Entity = $".."

func _ready() -> void:
	add_to_group("enemy")
	
func hit_request():
	hitbody_owner.receive_hit()
