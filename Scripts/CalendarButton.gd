extends Button

var date
var cal = Calendar.new()

@onready var color_rect = $ColorRect
@onready var color_rect_2 = $ColorRect2

func _process(_delta):
	if (date.year == cal.get_today().year) and (date.month == cal.get_today().month) and (date.day == cal.get_today().day):
		color_rect.visible = true
	else:
		color_rect.visible = false
		
	if Global.tasks.has(cal.get_date_formatted(date.year, date.month, date.day)):
		if Global.tasks[cal.get_date_formatted(date.year, date.month, date.day)] != []:
			color_rect_2.visible = true
		else:
			color_rect_2.visible = false
	else:
		color_rect_2.visible = false

func _on_pressed():
	get_tree().current_scene.load_day(cal.get_date_formatted(date.year, date.month, date.day))
	get_tree().current_scene._on_close_calendar_pressed()
