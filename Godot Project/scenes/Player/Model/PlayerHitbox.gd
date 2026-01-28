extends Area3D
class_name Hurtbox

@onready var model = $"../.." as PlayerModel

@export var processor : Node

func _physics_process(delta: float) -> void:
	if has_overlapping_areas():
		for area in get_overlapping_areas():
			on_area_contact(area)


	# Gab's original code has this check a bunch of stuff.
	# From what I can tell, weapons are area2Ds in gab's version. The weapon class has an ignore_list array.
	# so as soon as iT makes contact, it shuts itself off, essentially. 
	# the weapon also has an is_attacking bool which needs to be true for this to work.
	# this all makes sense for melee weapons, but doesn't so much with bullets.
	# BUT I will leave the comments there so we don't get confused later.


func  on_area_contact(area : Node3D):
	print(area.name)
	if is_eligible_attacking_bullet(area):
		#area.hitbox_ignore_list.append(self)
		print("registered hit. Uncomment Functionality in PlayerHitbox.gd when ready")
		#processor.current_move.react_on_hit(area.get_hit_data())


func is_eligible_attacking_bullet(area : Node3D) -> bool:
	if area is EnemyBullet: #and is_not_ignored(area) and not area.hitbox_ignore_list.has(self) and area.is_attacking:
		return true
	return false

#func is_not_ignored(area : Node3D) -> bool:
	#for group in ignored_weapon_groups:
		#If area.is_in_group(group):
			#return false
	#return true
