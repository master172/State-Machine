extends Node
class_name BaseStateMachine

signal state_transition(previous_state:BaseState,current_state:BaseState)

var owner_state_machine:BaseStateMachine

@export var resources:Resources
@export var animation_database:AnimationDataReferencer
@export var priority_dict:Dictionary[StringName,float] = {
	
}

var state_dict:Dictionary[StringName,BaseState] = {
	
}

var current_active_states:Array[BaseState]
var current_state:BaseState

#region child states population
func populate_state_dict()->void:
	for i:Node in get_children():
		if not i is BaseState:
			continue
		i = i as BaseState
		state_dict[i.name.to_lower()] = i
		state_dict.merge(i.get_child_states_dict())
		i.set_parent_state_machine(self)

func connect_signals()->void:
	for i:BaseState in state_dict.values():
		i.transition_state.connect(transition_to_state)

func set_paths()->void:
	for i:BaseState in state_dict.values():
		i.state_path = self.get_path_to(i)
#endregion

func _ready() -> void:
	populate_state_dict()
	connect_signals()
	set_paths()
	if current_state == null:
		current_state = get_child(0)
		current_active_states = get_base_state_array_from_string_array(
			get_state_array_from_path(
				current_state.state_path
				)
			)

#region update cycle
func _update_state_machine(input:InputPackage,delta:float)->void:
	if current_state == null:
		return
	state_update_function(input,delta)

func state_update_function(input:InputPackage,delta:float)->void:
	for i:BaseState in current_active_states:
		i._default_lifecycle(input)
		i._physics_update(delta)

#endregion

#region transitions
func transition_to_state(prev_state:BaseState,next_state:StringName)->void:
	var next_state_ref:BaseState = state_dict[next_state]
	
	var previous_state_array:PackedStringArray = get_state_array_from_path(prev_state.state_path)
	var next_state_array:PackedStringArray = get_state_array_from_path(next_state_ref.state_path)
	
	var least_common_ancestor:int = get_least_common_ancestor(previous_state_array,next_state_array)
	
	for i:int in range(current_active_states.size()-1,least_common_ancestor,-1):
		current_active_states[i]._on_exit()
	
	current_state = next_state_ref
	current_active_states = get_base_state_array_from_string_array(next_state_array)
	
	for i:int in range(least_common_ancestor+1,current_active_states.size()):
		current_active_states[i]._on_enter()
	
	state_transition.emit(prev_state,current_state)

func get_base_state_array_from_string_array(array:PackedStringArray)->Array[BaseState]:
	var returning_array:Array[BaseState]
	for i:String in array:
		returning_array.append(state_dict[i.to_lower()])
	return returning_array

func get_state_array_from_path(Path:NodePath)->PackedStringArray:
	var resulting_array:PackedStringArray = []
	resulting_array = str(Path).split("/")
	return resulting_array

func get_least_common_ancestor(previous_state_path:PackedStringArray,new_state_path:PackedStringArray)->int:
	var min_size:int = min(previous_state_path.size(),new_state_path.size())
	var least_common_ancestor:int = -1
	
	for i:int in range(min_size):
		if previous_state_path[i] != new_state_path[i]:
			return least_common_ancestor
		else:
			least_common_ancestor = i
	return least_common_ancestor
#endregion
