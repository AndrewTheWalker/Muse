extends Move
class_name Roll

func _ready():
	animation = "Roll"

func check_relevance(input : InputPackage):
	pass

func update(input : InputPackage, delta : float):
	pass

func on_enter_state():
	pass

func on_exit_state():
	pass


func move_player(delta : float):
	var delta_pos = get_root_position_delta(delta)
	delta_pos.y = 0
	var rotated_delta = player.get_quaternion() * delta_pos / delta
	player.velocity.x = rotated_delta.x
	player.velocity.z = rotated_delta.z
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
	player.move_and_slide()
