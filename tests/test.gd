extends Node2D

@export var base_state_machine: BaseStateMachine

func _physics_process(delta: float) -> void:
	base_state_machine._update_state_machine(delta)
