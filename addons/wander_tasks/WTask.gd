class_name WTask
extends RefCounted

signal on_task_complete

var is_active : bool = false


func _start()->void:
	is_active = true

func _complete()->void:
	is_active = false
	on_task_complete.emit()

#func _notification(what: int) -> void:
	#if what == NOTIFICATION_PREDELETE:
		#print("task deleted")
