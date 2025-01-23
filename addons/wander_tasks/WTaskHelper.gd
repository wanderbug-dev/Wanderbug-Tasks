extends Node

var _incrementer : int = 0

#region callable coroutines
## calls all callables and returns their values in the order compelted
func sync_callables(callables : Array[Callable])->Array:
	var current_increment := str(_increment())
	
	var return_values : Array
	return_values.resize(callables.size())
	
	var completion_count : Array[int] = [0] #pass by reference to lambda
	var on_complete := Signal(self, current_increment)
	add_user_signal(current_increment)
	
	var await_callable := func (callable : Callable)->void:
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

## calls all callables and returns their values in the order compelted
## each nested array should have a callable at index 0 and an array of args at index 1
func sync_callables_args(callables : Array[Array])->Array:
	var current_increment := str(_increment())
	
	var return_values : Array
	return_values.resize(callables.size())
	
	var completion_count : Array[int] = [0]
	var on_complete := Signal(self, current_increment)
	add_user_signal(current_increment)
	
	var await_callable := func (callable_data : Array)->void:
		var callable := callable_data[0] as Callable
		var value = await callable.callv(callable_data[1])
		return_values[completion_count[0]] = value
		completion_count[0] += 1
		if completion_count[0] >= callables.size():
			on_complete.emit()
	
	for callable_data in callables:
		await_callable.call_deferred(callable_data)
	await on_complete
	remove_user_signal(current_increment)
	return return_values

## calls all callables and returns the value of the first completed
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

## calls all callables one by one and returns their values in order
func sequence_callables(callables : Array[Callable])->Array:
	var return_values : Array
	return_values.resize(callables.size())
	for i in callables.size():
		return_values[i] = await callables[i].call()
	return return_values

## calls the callable after the specified delay and awaits its return value
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

func race_signals(signals : Array[Signal])->Variant:
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
