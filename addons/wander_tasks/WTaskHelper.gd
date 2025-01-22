extends Node

var _incrementer : int = 0


func sync_callables_task(callables : Array[Callable])->WTask_SyncCallables:
	var sync_task := WTask_SyncCallables.new()
	sync_task.callables = callables
	sync_task._start.call_deferred() #defer start in case callables immediately return
	await sync_task.on_task_complete
	return sync_task

func sync_callables(callables : Array[Callable])->Array:
	# we can create everything within the function itself as an alternative to task objects
	# maybe this is more performant?
	_incrementer += 1
	var current_increment := _incrementer
	
	var return_values : Array
	return_values.resize(callables.size())
	
	var completion_count : Array[int] = [0] # to write to this within the inner function scope it must be an array to be passed by reference
	var on_complete := Signal(self, str(current_increment))
	add_user_signal(str(current_increment))
	
	var await_callable := func (callable : Callable):
		var value = await callable.call()
		return_values[completion_count[0]] = value
		completion_count[0] += 1
		if completion_count[0] >= callables.size():
			on_complete.emit()
	
	for callable in callables:
		await_callable.call_deferred(callable)
	await on_complete
	remove_user_signal(str(current_increment))
	return return_values

func race_callables_task(callables : Array[Callable])->WTask_RaceCallables:
	var race_task := WTask_RaceCallables.new()
	race_task.callables = callables
	race_task._start.call_deferred() #defer start in case callables immediately return
	await race_task.on_task_complete
	return race_task

func race_callables(callables : Array[Callable])->Variant:
	_incrementer += 1
	var current_increment := _incrementer
	
	var on_complete := Signal(self, str(current_increment))
	add_user_signal(str(current_increment))
	
	var await_callable := func (callable : Callable):
		var value = await callable.call()
		if has_user_signal(str(current_increment)):
			on_complete.emit(value)
	
	for callable in callables:
		await_callable.call_deferred(callable)
	var return_value : Variant = await on_complete
	remove_user_signal(str(current_increment))
	return return_value

func sequence_callables(callables : Array[Callable])->Array:
	var return_values : Array
	return_values.resize(callables.size())
	for i in callables.size():
		return_values[i] = await callables[i].call()
	return return_values
