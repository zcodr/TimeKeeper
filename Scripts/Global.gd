extends Node

var tasks : Dictionary

func _ready():
	load_app()

func save():
	var save_dict = {
		"tasks" : tasks
	}
	return save_dict

func save_app():
	var save_app = FileAccess.open("user://saveapp.save", FileAccess.WRITE)

	var json_string = JSON.stringify(save())
	
	save_app.store_line(json_string)

func load_app():
	if not FileAccess.file_exists("user://saveapp.save"):
		return
	
	var save_app = FileAccess.open("user://saveapp.save", FileAccess.READ)
	
	var ZESTY = 0
	while save_app.get_position() < save_app.get_length():
		var json_string = save_app.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		var node_data = json.get_data()
		
		print(node_data)
		tasks = node_data["tasks"]
