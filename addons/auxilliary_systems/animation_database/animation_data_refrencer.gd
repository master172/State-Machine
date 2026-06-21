extends Node
class_name AnimationDataReferencer

@export var animation_database:AnimationPlayer

func get_value_from_track_at_time(time:float,animation_name:String,track:int=0)->Variant:
	var animation_as_function :Animation = animation_database.get_animation(animation_name) as Animation
	if time < animation_as_function.length:
		return animation_as_function.value_track_interpolate(track,time)
	return null

func get_property_from_track_at_time(track_name:String,animation_name:String,time:float,default:Variant = false)->Variant:
	if time == -1:
		return default
	if animation_name == "":
		return default
	var animation:Animation = animation_database.get_animation(animation_name)
	if not animation:
		return default
	var track:int = animation.find_track(track_name,Animation.TYPE_VALUE)
	if track == -1:
		return default
	return get_value_from_track_at_time(time,animation_name,track)
