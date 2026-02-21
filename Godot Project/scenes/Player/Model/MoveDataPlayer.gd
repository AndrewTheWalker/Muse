extends AnimationPlayer


# Each one of these variables is an animatable quality. 
# this enables particular "windows" to be applied. Invulnerability, precise moments where queued moves may activate, etc.
# when called to do so, the movedata script will query this one to check transition validity.

@export var root_position : Vector3
@export var transitions_to_queued : bool
@export var accepts_queueing : bool
@export var is_vulnerable : bool
@export var is_interruptable : bool
@export var tracks_input_vector : bool
@export var can_shoot : bool


func get_boolean_value(animation : String, track_name : String, timecode : float) -> bool:
	var data = get_animation(animation)
	var track = data.find_track(track_name, Animation.TYPE_VALUE)
	return data.value_track_interpolate(track, timecode)
