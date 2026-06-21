extends Node
class_name BaseStateMachine


var owner_state_machine:BaseStateMachine

@export var priority_dict:Dictionary[StringName,float] = {
	
}

var state_dict:Dictionary[StringName,BaseState] = {
	
}

var current_active_states:Array[BaseState]
var current_state:BaseState

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

func _ready() -> void:
	populate_state_dict()
	connect_signals()
	if current_state == null:
		current_state = get_child(0)

func _update_state_machine(delta:float)->void:
	if current_state == null:
		return
	current_state._default_lifecycle()
	current_state._physics_update(delta)

#region transitions
func transition_to_state(prev_state:BaseState,next_state:StringName)->void:
	prev_state._on_exit()
	current_state = state_dict[next_state]
	current_state._on_enter()


#endregion
