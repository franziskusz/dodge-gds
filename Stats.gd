extends Node

var performance: Performance
var second: int
var mobs_spawned: int
var hits: int
var fps: float
var memory_static: float
var timestamp_micros: int
var file_path: String

func update_stats(main_second: int, main_mobs_spawned, main_hits: int, main_fps: float):
	second = main_second
	mobs_spawned = main_mobs_spawned
	hits = main_hits
	fps = main_fps
	
	var memory_monitor: Performance.Monitor = Performance.MEMORY_STATIC
	memory_static = Performance.get_monitor(memory_monitor)
	
	var unix_timestamp_seconds: float
	unix_timestamp_seconds = Time.get_unix_time_from_system()
	timestamp_micros = int(unix_timestamp_seconds * 1000000)
	
	write_to_csv()
	
	print("ts, second, mobs, hits, fps, memory " + str(timestamp_micros) + " " + str(second) + " " + str(mobs_spawned) + " " + str(fps) + " " + str(memory_static))
	
func write_to_csv():
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE) #open file without truncating
	#use FileAccess.WRITE_READ or .WRITE if file is ought to be truncated with every run
	
	if file.get_length() == 0:
		var header = PackedStringArray(["timestamp", "second", "mobs_spawned", "hits", "fps"])
		file.store_csv_line(header, ",")
	
	file.seek_end(0) #move cursor to the end
	
	var line = PackedStringArray([str(timestamp_micros), str(second), str(mobs_spawned), str(hits), str(fps)])
	
	file.store_csv_line(line, ",")

func create_file_path_for_current_run():
	var unix_timestamp_seconds: String
	unix_timestamp_seconds = str(int(Time.get_unix_time_from_system()))
	var suffix: String = ".csv"
	var path: String = "user://stats/godot-gds-" + unix_timestamp_seconds + suffix
	file_path = path
	
	if !FileAccess.file_exists(file_path):
		var _file = FileAccess.open(file_path, FileAccess.WRITE)	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("../../Main").send_stats.connect(update_stats)
	
	get_node("../../Main/HUD").start_game.connect(create_file_path_for_current_run)
	
	var user_directory = DirAccess.open("user://")
	
	if !user_directory.dir_exists("stats"):
		user_directory.make_dir("stats")
		
		
	print("stats_ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
