extends Node
class_name EventBus

@export var subscribers:Dictionary[StringName,Array] = {
}

func subscribe(event:StringName,callback:Callable)->void:
	if not subscribers.has(event):
		subscribers[event] = []
	subscribers[event].append(callback)

func unsubscribe(event:StringName,callback:Callable)->void:
	if not subscribers.has(event):
		return
	subscribers[event].erase(callback)

func broadcast(event:StringName,data:Array[Variant])->void:
	if not subscribers.has(event):
		return
	
	for callback:Callable in subscribers[event]:
		callback.callv(data)
