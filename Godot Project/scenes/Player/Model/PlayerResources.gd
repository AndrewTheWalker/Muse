extends Node
class_name PlayerResources

# this is where we store health and stamina and whatnot, and where we do the calculations.

@export var god_mode : bool = false

@export var health : float = 100
@export var max_health : float = 100

@export var stamina : float = 100
@export var max_stamina : float = 100
@export var stamina_regeneration_rate : float = 15  # per sec, because then we'll multiply on delta

@onready var model = $".." as PlayerModel

var statuses : Array[String]
const FATIGUE_THRESHOLD = 90


# these are all pretty self-explanatory.

func update(delta : float):
	gain_stamina(stamina_regeneration_rate * delta)

func pay_resource_cost(move : Move):
	lose_stamina(move.stamina_cost)


func can_be_paid(move : Move) -> bool:
	if stamina > 0 or move.stamina_cost == 0:
		return true
	return false


func lose_health(amount : float):
	if not god_mode:
		health -= amount
		SignalBus.LIFE_CHANGE.emit(health)
		print("player life changed to ", health)
		if health < 1:
			model.current_move.try_force_move("death")

func gain_health(amount : float):
	if health + amount <= max_health:
		health += amount
	else:
		health = max_health
	SignalBus.LIFE_CHANGE.emit(health)

func lose_stamina(amount : float):
	if not god_mode:
		stamina -= amount
		SignalBus.STAMINA_CHANGE.emit(stamina)
		if stamina < 1:
			statuses.append("fatigue")
			SignalBus.OVERHEATING.emit()


func gain_stamina(amount : float):
	if stamina + amount < max_stamina:
		stamina += amount
	else:
		stamina = max_stamina
	if stamina > FATIGUE_THRESHOLD:
		statuses.erase("fatigue")
	SignalBus.STAMINA_CHANGE.emit(stamina)
