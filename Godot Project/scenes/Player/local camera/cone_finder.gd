extends Node
class_name ConeFinder

@onready var camera = $".."
@onready var reticle: CanvasLayer = $"../CanvasLayer/Sprite2D"

@onready var target_node = $Enemy

# Example: If you want a 5-degree radius from the center
var angle_degrees = 5.0
var threshold = cos(deg_to_rad(angle_degrees)) 
# Result: ~0.996

var current_target: Node3D = null

'''This is a ton of gemini generated code. I'm attempting to sort through it'''

## Let me try to set out the order of operations here
# Step 1: When we enter aim mode, we run a query of all the targetable aspects in the scene.
# Step 1.5: This script only runs while we are in locked mode.
# Step 2: We cull that list down to what is in the FOV, and within a certain distance of the player.
# Step 3: We sort the available targetables based on some parameters we decide are important
# Step 3.5: As part of this sort, we find the one closest to the centre of the screen.
# In theory, if no target is within the threshold value, then we don't even worry about it.
# Step 4: Once we have an array of valid targetables, we define a function that determines 
# joystick sensitivity as a function of dot product, possibly using a curve resource? (easier to tweak than smoothstep or slerp)
# what I want is a default sensitivity, and then the sensitivity smoothly gets lower and lower the closer you get to the target
# this is updated every frame. We have to construct this script such that it doesn't bother doing expensive things if we
# don't meet the appropriate thresholds. I.e. if no targets on screen, return nothing.
# I think I have what I need to figure that out.


func _process(_delta):
	# Using 0.99 for a tight circle (~8 degrees total)
	var in_sight = is_target_visible_in_center(camera, target_node, 0.99)
	
	if in_sight:
		reticle.modulate = Color.RED   # Locked on
	else:
		reticle.modulate = Color.WHITE # Searching

	var targets = get_tree().get_nodes_in_group("enemies")
	var new_best = get_best_target(camera, targets)
	
	# Simple logic: If we have a target, it needs a higher threshold to 'lose' focus
	if new_best != current_target:
		current_target = new_best


func is_node_in_cone(camera: Camera3D, target: Node3D, threshold: float = 0.98) -> bool:
	var cam_forward = -camera.global_transform.basis.z.normalized()
	var to_target = (target.global_position - camera.global_position).normalized()
	
	# The dot product returns a value from -1 to 1
	var dot = cam_forward.dot(to_target)
	
	return dot > threshold


func is_target_visible_in_center(camera: Camera3D, target: Node3D, threshold: float) -> bool:
	var cam_pos = camera.global_position
	var target_pos = target.global_position
	
	# 1. Directional Check (The Circle)
	var cam_forward = -camera.global_transform.basis.z.normalized()
	var to_target = (target_pos - cam_pos).normalized()
	var dot = cam_forward.dot(to_target)
	
	if dot < threshold:
		return false # Outside the "circle"

	# 2. Line-of-Sight Check (The Obstacles)
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(cam_pos, target_pos)
	
	# Optional: Ignore the camera/player if they have collision
	query.exclude = [camera.get_parent()] 
	
	var result = space_state.intersect_ray(query)
	
	# If the ray hit nothing, or it hit the target itself, it's visible
	if result.is_empty() or result.collider == target:
		return true
		
	return false


## Threshold value references
# 0.999: Extremely precise (Sniper feel).
# 0.99: Standard circular focus (~8° cone).
# 0.95: Large "near-center" area (~18° cone).


func get_best_target(camera: Camera3D, targets: Array[Node3D], threshold: float = 0.98) -> Node3D:
	var best_target: Node3D = null
	var highest_dot: float = -1.0 # Start lower than any possible dot
	
	var cam_forward = -camera.global_transform.basis.z.normalized()
	
	for target in targets:
		# 1. Basic Direction Check
		var to_target = (target.global_position - camera.global_position).normalized()
		var dot = cam_forward.dot(to_target)
		
		# 2. Must be within the "circle" and better than the previous best
		if dot > threshold and dot > highest_dot:
			# 3. Line-of-Sight Check (Only check the 'best' candidates to save performance)
			if is_target_visible(camera, target):
				highest_dot = dot
				best_target = target
				
	return best_target


# Helper function to keep the loop clean
func is_target_visible(camera: Camera3D, target: Node3D) -> bool:
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, target.global_position)
	var result = space_state.intersect_ray(query)
	return result.is_empty() or result.collider == target
	



# Weights should add up to 1.0
@export var alignment_weight: float = 0.7  # How much we care about being centered
@export var distance_weight: float = 0.3   # How much we care about being close
@export var max_range: float = 50.0        # Targets beyond this are ignored

func get_scored_target(camera: Camera3D, targets: Array[Node3D], threshold: float = 0.95) -> Node3D:
	var best_target: Node3D = null
	var highest_score: float = -1.0
	
	var cam_pos = camera.global_position
	var cam_forward = -camera.global_transform.basis.z.normalized()
	
	for target in targets:
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
			if is_target_visible(camera, target):
				highest_score = final_score
				best_target = target
				
	return best_target

## something about using curve resources
#@export var distance_curve: Curve
#
# Inside the loop:
#var proximity_score = distance_curve.sample(1.0 - (distance / max_range))
