extends Area3D

@export var text : String = "default text"


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		SignalBus.HINT_REVEAL.emit(text)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		SignalBus.HINT_HIDE.emit()
