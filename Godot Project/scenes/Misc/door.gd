extends Node3D

@onready var door_close: AudioStreamPlayer3D = $DoorClose
@onready var door_open: AudioStreamPlayer3D = $DoorOpen
@onready var animation_player: AnimationPlayer = $AnimationPlayer



func open_door():
	animation_player.play("anim_door_open")
	door_open.play()

func close_door():
	animation_player.play("anim_door_close")
	door_close.play()

func stay_open():
	animation_player.play("is_open")
