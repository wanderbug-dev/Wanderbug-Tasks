extends Node

signal test_signal1(value : String)
signal test_signal2(value : String)
signal test_signal3(value : String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#await callable_sync_test() #prints ["1st", "2nd", "3rd"]
	await callable_args_sync_test() #prints ["1st", ["2nd", true], "3rd"]
	#await callable_race_test() #prints "1st"
	#await callable_sequence_test() #prints ["3rd", "1st", "2nd"]
	#await call_delay_test() #prints "delay"
	#await signal_sync_test() #prints ["1st", "2nd", "3rd"]
	#await signal_race_test() #prints ["1st", "2nd", "3rd"]

func callable_sync_test()->void:
	var test_func1 := func ()->String:
		await get_tree().create_timer(1.0).timeout
		return "3rd"
	var test_func2 := func ()->String:
		return "1st"
	var test_func3 := func ()->String:
		for i in 3:
			await get_tree().process_frame
		return "2nd"
	print("callable sync test: ")
	var return_values := await WTaskHelper.sync_callables([test_func1, test_func2, test_func3])
	print("	", return_values)

func callable_args_sync_test()->void:
	var test_func1 := func (arg : String)->String:
		await get_tree().create_timer(1.0).timeout
		return arg
	var test_func2 := func (arg : String)->String:
		return arg
	var test_func3 := func (arg1 : String, arg2 : bool)->Array:
		for i in 3:
			await get_tree().process_frame
		return [arg1, arg2]
	print("callable args sync test: ")
	var return_values := await WTaskHelper.sync_callables_args([
		[test_func1, ["3rd"]],
		[test_func2, ["1st"]],
		[test_func3, ["2nd", true]]
	])
	print("	", return_values)

func callable_race_test()->void:
	var test_func1 := func ()->String:
		await get_tree().create_timer(1.0).timeout
		return "3rd"
	var test_func2 := func ()->String:
		return "1st"
	var test_func3 := func ()->String:
		for i in 3:
			await get_tree().process_frame
		return "2nd"
	print("callable race test: ")
	var return_value = await WTaskHelper.race_callables([test_func1, test_func2, test_func3])
	print("	", return_value)

func callable_sequence_test()->void:
	var test_func1 := func ()->String:
		await get_tree().create_timer(1.0).timeout
		return "3rd"
	var test_func2 := func ()->String:
		return "1st"
	var test_func3 := func ()->String:
		for i in 3:
			await get_tree().process_frame
		return "2nd"
	print("callable sequence test: ")
	var return_values = await WTaskHelper.sequence_callables([test_func1, test_func2, test_func3])
	print("	", return_values)

func signal_sync_test()->void:
	print("signal sync test: ")
	var emit_signals := func ()->void:
		test_signal1.emit("1st")
		test_signal2.emit("2nd")
		test_signal3.emit("3rd")
	emit_signals.call_deferred()
	var return_values := await WTaskHelper.sync_signals([test_signal1, test_signal2, test_signal3])
	print("	", return_values)

func signal_race_test()->void:
	print("signal race test: ")
	var emit_signals := func ()->void:
		test_signal1.emit("1st")
		test_signal2.emit("2nd")
		test_signal3.emit("3rd")
	emit_signals.call_deferred()
	var return_value = await WTaskHelper.race_signals([test_signal1, test_signal2, test_signal3])
	print("	", return_value)

func call_delay_test()->void:
	var test_func := func ()->String:
		return "delay"
	print("call delay test: ")
	var return_value = await WTaskHelper.call_delayed(test_func, 1.0)
	print("	", return_value)
