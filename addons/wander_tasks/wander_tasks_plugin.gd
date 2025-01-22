@tool
extends EditorPlugin

const TASKMANAGER_NAME = "WTaskHelper"


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_autoload_singleton(TASKMANAGER_NAME, "res://addons/wander_tasks/WTaskHelper.gd")

func _exit_tree() -> void:
	remove_autoload_singleton(TASKMANAGER_NAME)
