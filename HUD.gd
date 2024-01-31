extends CanvasLayer

var is_safe: bool = true
var is_bot_player: bool = false

signal start_game

signal stop_game

signal safe_mode_switch(is_safe: bool)

signal bot_player_switch(is_bot_player: bool)

signal mob_spawn_rate(mob_spawn_rate: int)

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.set_wait_time(2.0)
	$MessageTimer.start()



func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$MessageLabel.text = "Dodge the\nCreeps"
	$MessageLabel.show()
	await get_tree().create_timer(2).timeout
	$StartButton.show()


func update_score(score: int):
	var label_text = "seconds survived: "
	$ScoreLabel.text = label_text + str(score)
	
func update_hits(hits: int):
	var label_text = "hits: "
	$HitLabel.text = label_text + str(hits)
	
func update_mob_counter_label(mob_counter: int):
	var label_text = "active mobs: "
	$MobLabel.text = label_text + str(mob_counter)

func update_fps(fps: float):
	var label_text = "fps: "
	$FramesLabel.text = label_text + str(fps)


func _on_StartButton_pressed():
	$StartButton.hide()
	$StopButton.show()
	$SafeModeSwitch.hide()
	$MobSpawnSlider.hide()
	$SpawnIntervallSlider.hide()
	$BotPlayerSwitch.hide()
	start_game.emit()

func on_stop_button_pressed():
	$StartButton.show()
	$StopButton.hide()
	$SafeModeSwitch.show()
	$MobSpawnSlider.show()
	$SpawnIntervallSlider.show()
	$BotPlayerSwitch.show()
	stop_game.emit()


func _on_MessageTimer_timeout():
	$MessageLabel.hide()

func on_safe_mode_switch():
	is_safe = !is_safe
	emit_signal("safe_mode_switch", is_safe)
	$SafeModeSwitch.text = "safe_mode: " + str(is_safe)
	
func init_bot_player_switch():
	$BotPlayerSwitch.connect("pressed", on_bot_player_switch)
	
func on_bot_player_switch():
	is_bot_player = !is_bot_player
	emit_signal("bot_player_switch", is_bot_player)
	$BotPlayerSwitch.text = "bot player: "+ str(is_bot_player)
	
func init_mob_spawn_slider():
	$MobSpawnSlider.set_use_rounded_values(true)
	$MobSpawnSlider.set_min(0.0)
	$MobSpawnSlider.set_max(100.0)
	$MobSpawnSlider.set_ticks_on_borders(true)
	
	$MobSpawnSlider.value_changed.connect(update_mob_spawn_label)
	update_mob_spawn_label(1.0)
	
func update_mob_spawn_label(slider_value: float):
	var mob_spawns = int(slider_value)
	$MobSpawnSlider/SliderLabel.text = str(mob_spawns)
	
func init_spawn_intervall_slider():
	$SpawnIntervallSlider.set_use_rounded_values(true)
	$SpawnIntervallSlider.set_min(1.0)
	$SpawnIntervallSlider.set_max(60.0)
	$SpawnIntervallSlider.set_ticks_on_borders(true)
	
	$SpawnIntervallSlider.value_changed.connect(update_spawn_intervall_slider)
	update_spawn_intervall_slider(1.0)
	
func update_spawn_intervall_slider(slider_value: float):
	var spawn_intervall_length = int(slider_value)
	$SpawnIntervallSlider/SliderNumberLabel.text = str(spawn_intervall_length)
	
func _ready():
	init_mob_spawn_slider()
	init_spawn_intervall_slider()
	init_bot_player_switch()
	$MessageTimer.timeout.connect(_on_MessageTimer_timeout)
	
	
	
