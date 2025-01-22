@tool
extends EditorPlugin

const TASKHELPER_NAME = "WTaskHelper"


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_autoload_singleton(TASKHELPER_NAME, "res://addons/wander_tasks/WTaskHelper.gd")

func _exit_tree() -> void:
	remove_autoload_singleton(TASKHELPER_NAME)
