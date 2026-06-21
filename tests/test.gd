extends Node2D

@export var base_state_machine: BaseStateMachine
@export var input_gatherer: InputGatherer

func _physics_process(delta: float) -> void:
	var input_package:InputPackage = input_gatherer.gather_input(delta)
	base_state_machine._update_state_machine(input_package,delta)
