extends Node

const FPS_LOWER_LIMIT: float = 20.0
@export var mob_scene: PackedScene
@export var player_position: Vector2
@export var is_safe: bool
var score: int
var hits: int
var mob_counter: int
var frames: int
var fps: float
var mob_spawns_per_second: int
var spawn_intervall_length: int
var wave_size: int

signal safe_mode_shutdown()

signal send_player_position(player_position: Vector2)

signal send_stats(second: int, mobs_spawned: int, hits: int, fps: float)


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


func new_game():
	get_tree().call_group(&"mobs", &"queue_free")
	score = 0
	hits = 0
	mob_counter = 0
	frames = 0
	
	var initial_wave_size = mob_spawns_per_second
	wave_size = initial_wave_size
	
	player_position = $StartPosition.position
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_hits(hits)
	$HUD.update_mob_counter_label(mob_counter)
	$HUD.show_message("Get Ready")
	$Music.play()

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	$FPSTimer.set_wait_time(1.0)
	$FPSTimer.start()
	
	var initial_wave_size = mob_spawns_per_second
	wave_size = initial_wave_size
	
func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)
	
func _on_fps_timer_timeout():
	var frames_var = float(frames)
	
	fps = frames_var
	frames = 0
	
	$HUD.update_fps(fps)
	
	emit_signal("send_stats", score, mob_counter, hits, fps)
	
	if is_safe:
		if fps < FPS_LOWER_LIMIT:
			print("fps limit")
			emit_signal("safe_mode_shutdown")
			
func on_hit_count():
	hits +=1
	$HUD.update_hits(hits)
	
func update_mob_counter(counter: int):
	mob_counter += counter
	$HUD.update_mob_counter_label(mob_counter)
	
	
	

func _on_MobTimer_timeout():
	var wave_size_float = float(wave_size)
	var spawn_intervall_length_float = float(spawn_intervall_length)
	var mob_spawns_per_second_float = float(mob_spawns_per_second)
	
	var loop_var: float = wave_size_float / spawn_intervall_length_float
	if loop_var < mob_spawns_per_second_float:
		wave_size += mob_spawns_per_second
	else:
		var i: int = 0
		while i < wave_size:
			i = i + 1
			spawn_mob()
	wave_size = mob_spawns_per_second

func spawn_mob():
	
	# Create a new instance of the Mob scene.
	var mob_scene = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node(^"MobPath/MobSpawnLocation")
	mob_spawn_location.progress = randi()

	# Set the mob's direction perpendicular to the path direction.
	#var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob_scene.position = mob_spawn_location.position

	# Add some randomness to the direction.
	#direction += randf_range(-PI / 4, PI / 4)
	#mob.rotation = direction
	
	var start_target: Vector2 = $Player.position
	var start_angle: float = mob_spawn_location.position.angle_to_point(start_target)
	mob_scene.rotation = start_angle

	# Choose the velocity for the mob.
	#var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	#mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	
	add_child(mob_scene)
	
	update_mob_counter(1)

func switch_safe_mode(safe_mode: bool):
	is_safe = safe_mode
	var is_safe_string = str(is_safe)
	print("safemode: " + is_safe_string)
	
func update_player_position(player_position_arg: Vector2):
	player_position = player_position_arg
	
func update_mob_spawn_rate(slider_value: float):
	var mob_spawns = int(slider_value)
	mob_spawns_per_second = mob_spawns
	
func update_spawn_intervall_length(slider_value: float):
	var intervall_length = int(slider_value)
	spawn_intervall_length = intervall_length
	
	
func _ready():
	$HUD.safe_mode_switch.connect(switch_safe_mode(true))
	
	$HUD/MobSpawnSlider.value_changed.connect(update_mob_spawn_rate(1))
	
	$HUD/SpawnInterVallSlider.value_changed.connect(update_spawn_intervall_length(1))
	
	$Player.send_player_position.connect(update_player_position($StartPosition.position))

func _process(delta):
	frames +=1


