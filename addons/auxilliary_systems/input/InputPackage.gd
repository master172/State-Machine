extends Resource
class_name InputPackage

@export var combat_intents:Array[StringName] = []

@export var combat_raw_actions:Array[StringName] = []
@export var combat_actions:Array[StringName] = []

@export var actions:Array[StringName] = []
@export var movement_actions:Array[StringName] = []
@export var input_direction:Vector2 = Vector2.ZERO

@export var interaction_actions:Array[StringName] = []

@export var forward_vector :float
@export var orbiting_vector:float

@export var target_position:Vector3

func clear_actions()->void:
	actions.clear()
	combat_actions.clear()
	combat_raw_actions.clear()
	combat_intents.clear()
	movement_actions.clear()
	interaction_actions.clear()
	
func get_forward()->float:
	return forward_vector

func get_orbiting()->float:
	return orbiting_vector
