extends Node2D

@onready var title = $CanvasLayer/UI/Title
@onready var text_field = $CanvasLayer/UI/VBoxContainer/TextField
@onready var task_container = $CanvasLayer/UI/VBoxContainer/TaskContainer

const TASK_LABEL = preload("res://Scenes/TaskLabel.tscn")

var date_selected

func _ready():
	load_day(Time.get_date_string_from_system())

func load_day(date : String):
	if date == Time.get_date_string_from_system():
		title.text = "Today"
	else:
		title.text = date
	
	for i in task_container.get_children():
		i.queue_free()
	for i in range(len(Global.tasks[date])):
		var task_label = TASK_LABEL.instantiate()
		task_container.add_child(task_label)
		task_label.index = i
		task_label.text = "- " + Global.tasks[date][i]
		
	date_selected = date

func _on_add_task_pressed():
	Global.tasks[date_selected].append(text_field.text)
	text_field.clear()
	print(Global.tasks)
	load_day(date_selected)

func _on_text_field_text_submitted(_new_text):
	_on_add_task_pressed()
