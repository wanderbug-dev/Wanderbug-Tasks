class_name WTask_SyncSignals
extends WTask

var signals : Array[Signal]
var return_values : Array[Variant]
var completion_count : int = 0:
	set(value):
		completion_count = value
		if completion_count >= signals.size():
			_complete()

func _start()->void:
	super()
	return_values.resize(signals.size())
	for sig in signals:
		await_signal(sig)

func await_signal(sig : Signal):
	var return_val = await sig
	return_values[completion_count] = return_val
	completion_count += 1
