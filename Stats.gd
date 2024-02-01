extends Node

var performance: Performance
var second: int
var mobs_spawned: int
var hits: int
var fps: float
var memory_static: float
var timestamp_nanos: int

func update_stats(main_second: int, main_mobs_spawned, main_hits: int, main_fps: float):
	second = main_second
	mobs_spawned = main_mobs_spawned
	hits = main_hits
	fps = main_fps
	
	var memory_monitor: Performance.Monitor = Performance.MEMORY_STATIC
	memory_static = Performance.get_monitor(memory_monitor)
	
	var unix_timestamp_seconds: float
	unix_timestamp_seconds = Time.get_unix_time_from_system()
	timestamp_nanos = int(unix_timestamp_seconds * 1000000000)
	
	write_to_csv()
	
	print("ts, second, mobs, hits, fps, memory " + str(timestamp_nanos) + " " + str(second) + " " + str(mobs_spawned) + " " + str(fps) + " " + str(memory_static))
	
func write_to_csv():
	var file = FileAccess.open("stats/stats.csv", FileAccess.READ_WRITE) #open file without truncating
	
	file.seek_end(0) #move cursor to the end
	
	var line = PackedStringArray([str(timestamp_nanos), str(second), str(mobs_spawned), str(hits), str(fps), str(memory_static)])
	
	file.store_csv_line(line, ",")
	
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	print("stats_ready")
	get_node("../../Main").send_stats.connect(update_stats)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
