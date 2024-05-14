extends Label

var index

func _on_delete_label_pressed():
	Global.tasks[get_tree().current_scene.date_selected].remove_at(index)
	get_tree().current_scene.load_day(get_tree().current_scene.date_selected)
	queue_free()
