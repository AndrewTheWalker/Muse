extends Node
class_name Spawner

var loc : Vector3
var next_loc : Vector3

var bullseye_scene = load("res://scenes/Misc/bullseye.tscn")

var current_children : Array

func _ready():
	spawn_target()

func get_new_loc()->Vector3:
	var a = randi_range(0,25)
	var b = randi_range(3,7)
	var c = randi_range(0,-40)
	var new_vec = Vector3(a,b,c)
	return new_vec

func spawn_target():
	var spawn_loc = get_new_loc()
	var to_spawn = bullseye_scene.instantiate()
	to_spawn.global_position = spawn_loc
	add_child(to_spawn)
	current_children.append(to_spawn)
	
	
