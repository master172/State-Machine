extends BaseState
class_name IdleState

var latch:bool = false

func default_lifecycle()->void:
	if !latch:
		latch = true
		print("update on ",self.name)
	if works_more_or_equal_to(1.5):
		emit_change_state("MoveState9")
