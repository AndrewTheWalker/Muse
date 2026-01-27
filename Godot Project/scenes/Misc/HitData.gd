extends Node
class_name HitData

#var is_parryable : bool
var damage : float
var hit_move_animation : String

var bullet : EnemyBullet

static func blank() -> HitData:
	return HitData.new()
