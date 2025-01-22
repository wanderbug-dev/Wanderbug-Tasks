extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await task_callable_sync_test()
	await callable_sync_test()
	await task_callable_race_test()
	await callable_race_test()
	await callable_sequence_test()

func task_callable_sync_test()->void:
	print("task callable sync test: ")
	var sync_task : WTask_SyncCallables = await WTaskHelper.sync_callables_task([test_func1, test_func2, test_func3])
	print("	", sync_task.return_values)

func callable_sync_test()->void:
	print("callable sync test: ")
	var return_values := await WTaskHelper.sync_callables([test_func1, test_func2, test_func3])
	print("	", return_values)

func task_callable_race_test()->void:
	print("task callable race test: ")
	var race_task : WTask_RaceCallables = await WTaskHelper.race_callables_task([test_func1, test_func2, test_func3])
	print("	", race_task.return_value)

func callable_race_test()->void:
	print("callable race test: ")
	var return_value = await WTaskHelper.race_callables([test_func1, test_func2, test_func3])
	print("	", return_value)

func callable_sequence_test()->void:
	print("callable sequence test: ")
	var return_values = await WTaskHelper.sequence_callables([test_func1, test_func2, test_func3])
	print("	", return_values)

func test_func1()->String:
	await get_tree().create_timer(1.0).timeout
	return "3rd"

func test_func2()->String:
	return "1st"

func test_func3()->String:
	for i in 3:
		await get_tree().process_frame
	return "2nd"
