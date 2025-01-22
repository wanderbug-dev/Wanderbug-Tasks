class_name WTask_SyncCallables
extends WTask

var callables : Array[Callable]
var return_values : Array[Variant]
var completion_count : int = 0:
	set(value):
		completion_count = value
		if completion_count >= callables.size():
			_complete()

func _start()->void:
	super()
	return_values.resize(callables.size())
	for callable in callables:
		await_callable(callable)

func await_callable(callable : Callable):
	var value = await callable.call()
	return_values[completion_count] = value
	completion_count += 1
