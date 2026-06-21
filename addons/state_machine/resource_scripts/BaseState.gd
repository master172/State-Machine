@abstract extends Node
class_name BaseState

signal transition_state(prev_state:BaseState,next_state:StringName)

var owning_state_machine:BaseStateMachine
var child_states:Dictionary[StringName,BaseState] = {
	
}

var state_enter_time:float

#region relative info population

func set_parent_state_machine(machine:BaseStateMachine)->void:
	owning_state_machine = machine
	if child_states.is_empty():
		return
	for i:BaseState in child_states.values():
		i.set_parent_state_machine(machine)

func populate_child_states_dict()->void:
	for i:Node in get_children():
		if not i is BaseState:
			continue
		child_states[i.name.to_lower()] = i

func get_child_states_dict()->Dictionary[StringName,BaseState]:
	var returning_dict:Dictionary[StringName,BaseState] = {}
	if child_states.is_empty():
		return returning_dict
	returning_dict.merge(child_states)
	for i:Node in get_children():
		if not i is BaseState:
			continue
		i = i as BaseState
		returning_dict.merge(i.get_child_states_dict())
	return returning_dict
#endregion

func _ready() -> void:
	populate_child_states_dict()

#region Time Awareness
func get_elasped_seconds()->float:
	return (Time.get_ticks_msec() - state_enter_time) /1000.0

func works_more_than(seconds:float)->bool:
	return get_elasped_seconds() > seconds

func works_less_than(seconds:float)->bool:
	return get_elasped_seconds() < seconds

func works_more_or_equal_to(seconds:float)->bool:
	return get_elasped_seconds() >= seconds

func works_less_or_equal_to(seconds:float)->bool:
	return get_elasped_seconds() <= seconds

#endregion

#region update cycle
func _on_enter()->void:
	state_enter_time = Time.get_ticks_msec()
	on_enter()

func _on_exit()->void:
	on_exit()

#NOTE mark abstract
func on_enter()->void:
	pass

#NOTE mark abstract
func on_exit()->void:
	pass

#NOTE mark abstract
func default_lifecycle()->void:
	pass

func _default_lifecycle()->void:
	default_lifecycle()

#NOTE mark abstract
func physics_update(delta:float)->void:
	pass

func _physics_update(delta:float)->void:
	physics_update(delta)

#endregion

#region transitions

func emit_change_state(next_state:StringName)->void:
	transition_state.emit(self,next_state.to_lower())

#endregion
