extends BaseState
class_name MoveState

var latch:bool = false

func default_lifecycle()->void:
	if !latch:
		latch = true
		print("update on ",self.name)
	if self.name.to_lower() == "movestate9" and works_more_or_equal_to(1.5):
		emit_change_state("MoveState12")
	elif self.name.to_lower() == "movestate12" and works_more_or_equal_to(1.5):
		emit_change_state("MoveState10")
