extends Node

var tasks : Dictionary

func _ready():
	tasks[Time.get_date_string_from_system()] = []
