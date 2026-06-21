extends BaseState
class_name IdleState

func default_lifecycle()->void:
	print(self.name)
	if works_more_or_equal_to(1.5):
		emit_change_state("MoveState9")
