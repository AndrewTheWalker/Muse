extends Node
class_name ConeFinder

@onready var local_camera : CameraModel = $".."
@onready var camera : Camera3D = $"../PlayerCamera"
@onready var reticle: AnimatedSprite2D = $"../CanvasLayer/Sprite2D"

#@onready var debugdraw: AimAssistDebugDraw = $debugdraw

@export var aim_curve : Curve

## Threshold value references
# 0.999: Extremely precise (Sniper feel).
# 0.99: Standard circular focus (~8° cone).
# 0.95: Large "near-center" area (~18° cone).
@export var angle_degrees = 4.0
var angle_threshold = cos(deg_to_rad(angle_degrees)) 



@export var dist_threshold = 50.0

## Weights should add up to 1.0
@export var alignment_weight : float = 0.7  # How much we care about being centered
@export var distance_weight : float = 0.3   # How much we care about being close
@export var max_range : float = 50.0        # Targets beyond this are ignored

var reticle_point : Vector3
var on_screen_targets : Array[Node3D]
var in_cone_targets :  Array[Node3D]

var aim_assist_strength_value : float = 0.0


func _ready():
	SignalBus.connect("TARGET_SCREEN_ENTERED",func(targetable): on_screen_targets.append(targetable))
	SignalBus.connect("TARGET_SCREEN_EXITED",func(targetable): on_screen_targets.erase(targetable))
	set_process(false)

func _process(delta: float) -> void:
	reticle_point = local_camera.find_reticle_point()
	if is_any_target_in_cone(reticle_point):
		var best_target = get_scored_target(reticle_point,angle_threshold)
		aim_assist_strength_value = get_friction_value(reticle_point,best_target)
	else:
		aim_assist_strength_value = 0.0

func is_any_target_in_cone(reticle_fwd:Vector3):
	##
	# this function takes the reticle point and checks to see if anything in the on_screen_targets array is within a
	# certain angle radius of the reticle point. If so, we append that target to an array of in_cone_targets and return true.
	var fwd = camera.global_position.direction_to(reticle_point).normalized()
	for target in on_screen_targets:
		var to_target = (target.global_position - camera.global_position).normalized()
		var dist = camera.global_position.distance_to(target.global_position)
		var dot = fwd.dot(to_target)
		if dot > angle_threshold and dist < dist_threshold:
			if is_target_visible(target):
				in_cone_targets.append(target)
	if !in_cone_targets.is_empty():
		return true

## so I have this second in_cone array. Obviously I need to refresh this array at some point, when do I do that?
# I guess I'll just keep going until I figure that out.


func is_target_visible(target: Node3D) -> bool:
	##
	# this is a pretty fun little function. I have no idea if it's overkill or not. 
	# what it does, is it querys the physics server to do a single raycast-esque check to see if the target is behind anything
	# we only proceed if so.
	# this is necessary to prevent aim assist from triggering for enemies behind walls.
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, target.global_position,2)
	var result = space_state.intersect_ray(query)
	return result.is_empty() or result.collider == target


func get_scored_target(fwd: Vector3, threshold: float = 0.95) -> Node3D:
	var best_target: Node3D = null
	var highest_score: float = -1.0
	
	var cam_pos = camera.global_position
	var cam_forward = camera.global_position.direction_to(fwd).normalized()
	
	if in_cone_targets.size() == 1:
		best_target = in_cone_targets[0]
		in_cone_targets.clear()
	
	if in_cone_targets.size() > 1:
		for target in in_cone_targets:
			var target_pos = target.global_position
			var distance = cam_pos.distance_to(target_pos)
			
			# 1. Distance Filter
			if distance > max_range:
				continue
				
			# 2. Alignment Calculation (0.0 to 1.0)
			var to_target = (target_pos - cam_pos).normalized()
			var dot = cam_forward.dot(to_target)
			
			if dot < threshold:
				continue # Not in the "circle"
				
			# 3. Normalize scores
			# Dot is already roughly 0 to 1 (within our threshold)
			var alignment_score = dot 
			
			# Invert distance so closer = higher score (1.0 at 0m, 0.0 at max_range)
			var proximity_score = 1.0 - (distance / max_range)
			
			# 4. Final Weighted Calculation
			var final_score = (alignment_score * alignment_weight) + (proximity_score * distance_weight)
			
			# 5. Best Score & Line-of-Sight Check
			if final_score > highest_score:
				if is_target_visible(target):
					highest_score = final_score
					best_target = target
			
			##
			# clear the array at this point because we already got what we needed, and we'll have a new array
			# by the time we run this again.
			in_cone_targets.clear()
	return best_target


func get_friction_value(reticle_vector:Vector3,target:Node3D) -> float:
	##
	# in this function, we calculate the dot once more, but this time we use the inverse_lerp function to normalize the range
	# therefore, close to the centre = 1, and close to the edge = 0. 
	# then, we will compare it against the pre-set curve to get another value between 0 and 1 that determines how strongly
	# the aim assist effect should be applied. The curve keeps things non-linear and therefore feeling nicer. It also allows
	# for customization down the line, with different weapons having different curve resources.  
	var fwd = camera.global_position.direction_to(reticle_vector).normalized()
	var to_target = (target.global_position - camera.global_position).normalized()
	var dot = fwd.dot(to_target)
	var dot_normalized = inverse_lerp(angle_threshold,1.0,dot)
	var curve_value = aim_curve.sample(dot_normalized)
	return curve_value
