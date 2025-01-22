class_name WTask
extends RefCounted

signal on_complete

var is_active : bool = false


func _start()->void:
	is_active = true

func _complete()->void:
	_end()
	on_complete.emit()

func _cancel()->void:
	_end()

func _end()->void:
	is_active = false
#func _notification(what: int) -> void:
	#if what == NOTIFICATION_PREDELETE:
		#print("task deleted")
