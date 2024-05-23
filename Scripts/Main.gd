extends Node2D

var location_url = "http://ip-api.com/json"
var prayer_url
@onready var location = $location_request
@onready var prayer = $prayer_request

@onready var title = $CanvasLayer/UI/Title
@onready var text_field = $CanvasLayer/UI/VBoxContainer/TextField
@onready var task_container = $CanvasLayer/UI/VBoxContainer/TaskContainer
@onready var calendar_panel = $CanvasLayer/UI/CalendarPanel
@onready var grid_container = $CanvasLayer/UI/CalendarPanel/GridContainer
@onready var month_label = $CanvasLayer/UI/CalendarPanel/MonthLabel
@onready var previous_month = $CanvasLayer/UI/CalendarPanel/PreviousMonth
@onready var previous_day = $CanvasLayer/UI/PreviousDay
@onready var prayer_panel = $CanvasLayer/UI/PrayerPanel
@onready var fajr = $CanvasLayer/UI/PrayerPanel/HBoxContainer/Fajr
@onready var sunrise = $CanvasLayer/UI/PrayerPanel/HBoxContainer/Sunrise
@onready var dhuhr = $CanvasLayer/UI/PrayerPanel/HBoxContainer/Dhuhr
@onready var asr = $CanvasLayer/UI/PrayerPanel/HBoxContainer/Asr
@onready var maghrib = $CanvasLayer/UI/PrayerPanel/HBoxContainer/Maghrib
@onready var isha = $CanvasLayer/UI/PrayerPanel/HBoxContainer/Isha
@onready var current = $CanvasLayer/UI/PrayerPanel/VBoxContainer/Current
@onready var next = $CanvasLayer/UI/PrayerPanel/VBoxContainer/Next

var cal = Calendar.new()

const TASK_LABEL = preload("res://Scenes/TaskLabel.tscn")
const CALENDAR_BUTTON = preload("res://Scenes/CalendarButton.tscn")

var date_selected
var month_selected
var todays_timings = []

func _ready():
	location.request_completed.connect(location_request)
	send_request(location, location_url)
	
	load_day(Time.get_date_string_from_system())
	var date_struct = Time.get_date_dict_from_system()
	load_calendar(date_struct["year"], date_struct["month"])
	
func send_request(httprequest : HTTPRequest, url : String):
	var headers = ["Content-Type: application/json"]
	httprequest.request(url, headers, HTTPClient.METHOD_GET)

func prayer_request(_results, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var timings = json["data"]["timings"]
	fajr.text = "Fajr\n" + mil_stand(timings["Fajr"])
	sunrise.text = "Sunrise\n" + mil_stand(timings["Sunrise"])
	dhuhr.text = "Dhuhr\n" + mil_stand(timings["Dhuhr"])
	asr.text = "Asr\n" + mil_stand(timings["Asr"])
	maghrib.text = "Maghrib\n" + mil_stand(timings["Maghrib"])
	isha.text = "Isha\n" + mil_stand(timings["Isha"])
	todays_timings.append(timings["Fajr"])
	todays_timings.append(timings["Sunrise"])
	todays_timings.append(timings["Dhuhr"])
	todays_timings.append(timings["Asr"])
	todays_timings.append(timings["Maghrib"])
	todays_timings.append(timings["Isha"])
	todays_timings.append(999999)
	
func location_request(_results, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var today = Time.get_date_string_from_system()
	var today_split = today.split("-")
	var today_string = today_split[2] + "-" + today_split[1] + "-" + today_split[0]
	prayer_url = "http://api.aladhan.com/v1/timings/:date=" + today_string + "?latitude=" + str(json["lat"]) + "&longitude=" + str(json["lon"]) + "&method=2"
	prayer.request_completed.connect(prayer_request)
	send_request(prayer, prayer_url)
	
func _process(_delta):
	if date_selected == Time.get_date_string_from_system():
		previous_day.disabled = true
	else:
		previous_day.disabled = false
		
	if (month_selected[0] == cal.get_today().year) and (month_selected[1] == cal.get_today().month):
		previous_month.disabled = true
	else:
		previous_month.disabled = false
	
	if not todays_timings.is_empty():
		var cur_time = Time.get_time_dict_from_system()
		var which_prayer = 6
		var cur_text = ""
		var next_text = ""
		for i in range(len(todays_timings)):
			var prayer_int = int(todays_timings[i])
			var cur_int = time_int(cur_time["hour"], cur_time["minute"])
			if cur_int >= prayer_int:
				which_prayer = i
		match which_prayer:
			0:
				cur_text = "Current\n\nFajr"
				next_text = "Ends at " + mil_stand(todays_timings[1])
			1:
				cur_text = " "
				next_text = "Next\n\nDhuhr at " + mil_stand(todays_timings[2])
			2:
				cur_text = "Current\n\nDhuhr"
				next_text = "Next\n\nAsr at " + mil_stand(todays_timings[3])
			3:
				cur_text = "Current\n\nAsr"
				next_text = "Next\n\nMaghrib at " + mil_stand(todays_timings[4])
			4:
				cur_text = "Current\n\nMaghrib"
				next_text = "Next\n\nIsha at " + mil_stand(todays_timings[5])
			5:
				cur_text = "Curent\n\nIsha"
				next_text = "Ends at Midnight"
			6:
				cur_text = " "
				next_text = "Fajr at " + mil_stand(todays_timings[0])
		current.text = cur_text
		if cur_text == " ":
			current.visible = false
		else:
			current.visible = true
		next.text = next_text
				
func mil_stand(mil_time : String):
	var hour = int(mil_time.split(":")[0])
	var minu =  mil_time.split(":")[1]
	if hour == 0:
		return "12:" + minu + " am"
	if hour == 12:
		return "12:" + minu + " pm"
	if hour > 12:
		return str(hour - 12) + ":" + minu + " pm"
	return str(hour) + ":" + minu + " am"
	
func time_int(hours : int, minus : int):
	return (100 * hours) + minus

func load_day(date : String):
	var todays_unix = Time.get_unix_time_from_datetime_string(Time.get_date_string_from_system())
	
	var date_split = date.split("-")
	var day_of_week = cal.get_weekday_formatted(int(date_split[0]), int(date_split[1]), int(date_split[2]))
	
	if date == Time.get_date_string_from_system():
		title.text = "Today" + "\n" + date_split[1] + "/" + date_split[2] + "/" + date_split[0]
	elif date == Time.get_date_string_from_unix_time(todays_unix + 86400):
		title.text = "Tomorrow" + "\n" + date_split[1] + "/" + date_split[2] + "/" + date_split[0]
	else:
		title.text = day_of_week + "\n" + date_split[1] + "/" + date_split[2] + "/" + date_split[0]
	
	for i in task_container.get_children():
		i.queue_free()
	if not Global.tasks.has(date):
		Global.tasks[date] = []
	for i in range(len(Global.tasks[date])):
		var task_label = TASK_LABEL.instantiate()
		task_container.add_child(task_label)
		task_label.index = i
		task_label.text = "- " + Global.tasks[date][i]
		
	date_selected = date

func load_calendar(year: int, month : int):
	month_selected = [year, month]
	for i in grid_container.get_children():
		i.queue_free()
	month_label.text = cal.get_month_formatted(month) + ", " + str(year)
	var calendar_struct = cal.get_calendar_month(year, month, true, true)
	for i in calendar_struct:
		for j in i:
			var new_button = CALENDAR_BUTTON.instantiate()
			grid_container.add_child(new_button)
			if typeof(j) == TYPE_INT:
				if j == 0:
					new_button.text = " "
					new_button.flat = true
					new_button.disabled = true
			else:
				new_button.text = str(j.day)
				new_button.date = j
				if j.is_before(cal.get_today()):
					new_button.disabled = true
			

func _on_add_task_pressed():
	if text_field.text.is_empty():
		return
	Global.tasks[date_selected].append(text_field.text)
	text_field.clear()
	load_day(date_selected)
	Global.save_app()

func _on_text_field_text_submitted(_new_text):
	_on_add_task_pressed()

func _on_next_day_pressed():
	var unix_time = Time.get_unix_time_from_datetime_string(date_selected) + 86400
	load_day(Time.get_date_string_from_unix_time(unix_time))

func _on_previous_day_pressed():
	if date_selected == Time.get_date_string_from_system():
		return
	var unix_time = Time.get_unix_time_from_datetime_string(date_selected) - 86400
	load_day(Time.get_date_string_from_unix_time(unix_time))

func _on_view_calendar_pressed():
	calendar_panel.visible = true

func _on_close_calendar_pressed():
	calendar_panel.visible = false

func _on_next_month_pressed():
	if (month_selected[1] + 1) == 13:
		load_calendar(month_selected[0] + 1, 1)
	else:
		load_calendar(month_selected[0], month_selected[1] + 1)

func _on_previous_month_pressed():
	if (month_selected[0] == cal.get_today().year) and (month_selected[1] == cal.get_today().month):
		return
	if (month_selected[1] - 1) == 0:
		load_calendar(month_selected[0] - 1, 12)
	else:
		load_calendar(month_selected[0], month_selected[1] - 1)

func _on_view_prayers_pressed():
	prayer_panel.visible = true

func _on_close_prayers_pressed():
	prayer_panel.visible = false
