extends Node

var tasks : Dictionary

func _ready():
	for i in range(365):
		var unix_time = Time.get_unix_time_from_system() + (86400 * i)
		tasks[Time.get_date_string_from_unix_time(unix_time)] = []
