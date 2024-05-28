extends Node

var tasks : Dictionary
var cal = Calendar.new()

func _ready():
	load_app()

func save():
	var save_dict = {
		"tasks" : tasks
	}
	return save_dict

func save_app():
	var lsave_app = FileAccess.open("user://saveapp.save", FileAccess.WRITE)

	var json_string = JSON.stringify(save())
	
	lsave_app.store_line(json_string)

func load_app():
	if not FileAccess.file_exists("user://saveapp.save"):
		return
	
	var lsave_app = FileAccess.open("user://saveapp.save", FileAccess.READ)
	
	while lsave_app.get_position() < lsave_app.get_length():
		var json_string = lsave_app.get_line()
		var json = JSON.new()
		var _parse_result = json.parse(json_string)
		var node_data = json.get_data()
		
		tasks = node_data["tasks"]
	
	for i in tasks.keys():
		var split = i.split("-")
		var year = int(split[0])
		var month = int(split[1])
		var day = int(split[2])
		
		if year < cal.get_today().year:
			tasks.erase(i)
			continue
		if year > cal.get_today().year:
			continue
		
		if month < cal.get_today().month:
			tasks.erase(i)
			continue
		if month > cal.get_today().month:
			continue
			
		if day < cal.get_today().day:
			tasks.erase(i)
			continue
		if day > cal.get_today().day:
			continue
