extends StaticBody3D
class_name HitBody

@onready var hitbody_owner = $".."

@export var type : String

# the value of "type" must EXACTLY match the name of the group, either player or enemy.
# actually it doesn't, for the moment the bullet doesn't use groups, it just checks the value of type.
# What I DO need to keep in mind is that because I'm not using the Entity class at the moment, so
# calling "receive_hit()" is a little risky because I have to manually add that function to every owner.


func _ready() -> void:
	add_to_group(type)
	
func hit_request():
	print("received hit!")
	hitbody_owner.receive_hit()
