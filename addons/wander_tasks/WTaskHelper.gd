extends Node

var _incrementer : int = 0

#region callable coroutines
func sync_callables_task(callables : Array[Callable])->WTask_SyncCallables:
	var sync_task := WTask_SyncCallables.new()
	sync_task.callables = callables
	sync_task._start.call_deferred() #defer start in case callables immediately return
	await sync_task.on_complete
	return sync_task

func sync_callables(callables : Array[Callable])->Array:
	var current_increment := str(_increment())
	
	var return_values : Array
	return_values.resize(callables.size())
	
	var completion_count : Array[int] = [0] #pass by reference to lamda
	var on_complete := Signal(self, current_increment)
	add_user_signal(current_increment)
	
	var await_callable := func (callable : Callable):
		var value = await callable.call()
		return_values[completion_count[0]] = value
		completion_count[0] += 1
		if completion_count[0] >= callables.size():
			on_complete.emit()
	
	for callable in callables:
		await_callable.call_deferred(callable)
	await on_complete
	remove_user_signal(current_increment)
	return return_values

func race_callables_task(callables : Array[Callable])->WTask_RaceCallables:
	var race_task := WTask_RaceCallables.new()
	race_task.callables = callables
	race_task._start.call_deferred()
	await race_task.on_complete
	return race_task

func race_callables(callables : Array[Callable])->Variant:
	var current_increment := str(_increment())
	
	var on_complete := Signal(self, current_increment)
	add_user_signal(current_increment)
	
	var await_callable := func (callable : Callable):
		var value = await callable.call()
		if has_user_signal(current_increment):
			on_complete.emit(value)
	
	for callable in callables:
		await_callable.call_deferred(callable)
	var return_value : Variant = await on_complete
	remove_user_signal(current_increment)
	return return_value

func sequence_callables(callables : Array[Callable])->Array:
	var return_values : Array
	return_values.resize(callables.size())
	for i in callables.size():
		return_values[i] = await callables[i].call()
	return return_values

func call_delayed(callable : Callable, delay : float, args : Array = [])->Variant:
	if delay <= 0:
		await get_tree().process_frame
		return await callable.callv(args)
	else:
		await get_tree().create_timer(delay).timeout
		return await callable.callv(args)

#endregion

#region signal coroutines
func sync_signals(signals : Array[Signal])->Array:
	var current_increment := str(_increment())
	
	var return_values : Array
	return_values.resize(signals.size())
	
	var completion_count : Array[int] = [0]
	var on_complete := Signal(self, current_increment)
	add_user_signal(current_increment)
	
	var await_signal := func (sig : Signal):
		var value = await sig
		return_values[completion_count[0]] = value
		completion_count[0] += 1
		if completion_count[0] >= signals.size():
			on_complete.emit()
	
	for sig in signals:
		await_signal.call(sig)
	await on_complete
	remove_user_signal(current_increment)
	return return_values

func race_signals(signals : Array[Signal])->Array:
	var current_increment := str(_increment())
	
	var on_complete := Signal(self, current_increment)
	add_user_signal(current_increment)
	
	var await_signal := func (sig : Signal):
		var value = await sig
		if has_user_signal(current_increment):
			on_complete.emit(value)
	
	for sig in signals:
		await_signal.call(sig)
	var return_value : Variant = await on_complete
	remove_user_signal(current_increment)
	return return_value

#endregion

func _increment()->int:
	_incrementer += 1
	return _incrementer
