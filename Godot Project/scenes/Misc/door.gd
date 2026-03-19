extends Node3D

@onready var door_close: AudioStreamPlayer3D = $DoorClose
@onready var door_open: AudioStreamPlayer3D = $DoorOpen
@onready var animation_player: AnimationPlayer = $AnimationPlayer



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		open_door()
		
func open_door():
	animation_player.play("anim_door_open")
	door_open.play()

func close_door():
	animation_player.play("anim_door_close")
	door_close.play()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		close_door()
