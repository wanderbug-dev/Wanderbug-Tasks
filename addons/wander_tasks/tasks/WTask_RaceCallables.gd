class_name WTask_RaceCallables
extends WTask

var callables : Array[Callable]
var return_value : Variant


func _start()->void:
	super()
	for callable in callables:
		await_callable(callable)

func await_callable(callable : Callable):
	var return_val = await callable.call()
	if not is_active:
		return
	return_value = return_val
	_complete()
