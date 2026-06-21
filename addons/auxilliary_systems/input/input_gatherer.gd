extends Node
class_name InputGatherer

var input_package:InputPackage

var time_since_left_push:float = 0.0
var time_since_right_push:float = 0.0

static var activation_time:float = 0.2

func _ready() -> void:
	input_package = InputPackage.new()

func gather_input(delta:float)->InputPackage:
	clear_package()
	
	input_package.forward_vector  = Input.get_axis("w","s")
	input_package.orbiting_vector = Input.get_axis("a","d")
	input_package.input_direction = Input.get_vector("a","d","w","s")
	
	#region mouse_input
	if Input.is_action_pressed("mouse_left"):
		if time_since_left_push == 0.0:
			input_package.combat_raw_actions.append(&"mouse_left_click_progressive")
		time_since_left_push += delta
	
	if time_since_left_push >= activation_time:
		input_package.combat_raw_actions.append(&"mouse_left_hold")
		
	if Input.is_action_just_released("mouse_left"):
		if time_since_left_push <= activation_time:
			input_package.combat_raw_actions.append(&"mouse_left_click_exclusive")
		time_since_left_push = 0.0
		input_package.combat_raw_actions.append(&"mouse_left_release")
	
	if Input.is_action_pressed("mouse_right"):
		if time_since_right_push == 0.0:
			input_package.combat_raw_actions.append(&"mouse_right_click_progressive")
		time_since_right_push += delta
	
	if time_since_right_push >= activation_time:
		input_package.combat_raw_actions.append(&"mouse_right_hold")
	
	if Input.is_action_just_released("mouse_right"):
		if time_since_right_push <= activation_time:
			input_package.combat_raw_actions.append(&"mouse_right_click_exclusive")
		time_since_right_push = 0.0
		input_package.combat_raw_actions.append(&"mouse_right_release")
		
	#endregion
	
	if Input.is_action_pressed("shift") and input_package.input_direction != Vector2.ZERO:
		input_package.movement_actions.append(&"shift_click")
		
	if Input.is_action_pressed("space"):
		input_package.movement_actions.append(&"space_click")
	
	if Input.is_action_just_pressed("f"):
		if input_package.input_direction != Vector2.ZERO:
			input_package.movement_actions.append(&"shift_f_click")
		else:
			input_package.movement_actions.append(&"f_click")
		
	
	if input_package.input_direction != Vector2.ZERO:
		input_package.movement_actions.append(&"directional_input")
	if input_package.input_direction == Vector2.ZERO:
		input_package.movement_actions.append(&"no_input")
	
	if Input.is_action_just_pressed("e"):
		input_package.interaction_actions.append(&"interact")
	
	return input_package

func clear_package()->void:
	input_package.movement_actions = []
	input_package.combat_actions = []
	input_package.actions = []
	input_package.combat_raw_actions = []
	input_package.combat_intents = []
	input_package.interaction_actions = []
