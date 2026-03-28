extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("entered electric floor")
		SignalBus.ELECTRIC_ENTERED.emit()


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("exited electric floor")
		SignalBus.ELECTRIC_EXITED.emit()
