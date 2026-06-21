@abstract extends Node
class_name BaseState

@export_group("resources")
@export var cost_type:StringName = &"health"
@export var cost_amount:float = 0.0

@export_group("state_variables")
@export var can_transition_to_self:bool = false


signal transition_state(prev_state:BaseState,next_state:StringName)

var owning_state_machine:BaseStateMachine
var child_states:Dictionary[StringName,BaseState] = {
	
}

var state_path:NodePath
var state_enter_time:float

var forced_state_name:StringName
var has_forced_state:bool = false

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
func default_lifecycle(input:InputPackage)->void:
	pass

func _default_lifecycle(input:InputPackage)->void:
	if has_forced_state:
		has_forced_state = false
		var temp_forced_state:StringName = forced_state_name
		forced_state_name = ""
		emit_change_state(temp_forced_state)
		return
	default_lifecycle(input)

#NOTE mark abstract
func physics_update(delta:float)->void:
	pass

func _physics_update(delta:float)->void:
	physics_update(delta)

#endregion

#region transitions
func try_forced_move(new_forced_state:StringName)->void:
	new_forced_state = new_forced_state.to_lower()
	var move_priority:Dictionary[StringName,float] = owning_state_machine.priority_dict
	if not has_forced_state:
		has_forced_state = true
		forced_state_name = new_forced_state
	elif move_priority[new_forced_state] > move_priority[forced_state_name]:
		forced_state_name = new_forced_state
		
func move_priority_sort(a:StringName,b:StringName)->bool:
	var move_priority:Dictionary[StringName,float] = owning_state_machine.priority_dict
	return move_priority[a] > move_priority[b]
	
func filter_inputs(input:InputPackage)->Array[StringName]:
	var result:Array[StringName] = []
	var possible_actions:Array[StringName] = input.actions.duplicate()
	for action:StringName in possible_actions:
		if not owning_state_machine.state_dict.has(action):
			continue
		var state:BaseState = owning_state_machine.state_dict[action]
		if owning_state_machine.resources.can_be_paid(state.cost_type,state.cost_amount):
			result.append(action)
	return result
	
func get_best_possible_state(input:InputPackage)->StringName:
	var possible_states:Array[StringName] = filter_inputs(input)
	if possible_states.is_empty():
		return &"Invalid"
	possible_states.sort_custom(move_priority_sort)
	return possible_states[0]
	
func emit_change_state(next_state:StringName)->void:
	transition_state.emit(self,next_state.to_lower())

#endregion

#region database
func get_property_at_time(track_name:String,animation_name:String,time:float)->Variant:
	if owning_state_machine.animation_database == null:
		push_error("trying to reference data from animation database but no database assigned")
	return owning_state_machine.animation_database.get_property_from_track_at_time(track_name,animation_name,time)

#endregion
