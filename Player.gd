extends Area2D

@export var speed: int = 400 # How fast the player will move (pixels/sec).
@export var player_position: Vector2
var input_position: Vector2
var is_bot: bool = false
var bot_direction: Vector2 = Vector2(-0.4,0.4)
var screen_size: Vector2 # Size of the game window.


signal hit

signal send_player_position(player_position: Vector2)

func _on_Player_body_entered(_body):
	#hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	#$CollisionShape2D.set_deferred(&"disabled", true)
	
func start(pos):
	position = pos
	player_position = pos
	input_position = pos
	show()
	$CollisionShape2D.disabled = false
	
	if is_bot:
		$BotTimer.set_wait_time(2.0)
		$BotTimer.start()
		bot_direction = Vector2(-0.4,0.4)


func despawn():
	hide()
	
func update_bot_mode(bot_mode: bool):
	is_bot = bot_mode

func update_bot_direction():
	if bot_direction == Vector2.UP:
		bot_direction = Vector2.RIGHT
	elif bot_direction == Vector2.RIGHT:
		bot_direction = Vector2.DOWN
	elif bot_direction == Vector2.DOWN:
		bot_direction = Vector2.LEFT
	elif bot_direction == Vector2.LEFT:
		bot_direction = Vector2.UP
	else:
		bot_direction = Vector2.UP

func handle_input(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	
	if is_bot:
		velocity += bot_direction
	
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1

	if velocity.length() > 1:
		velocity = velocity.normalized() * speed
	elif velocity.length() > 0:
		velocity = velocity *speed
		
	if velocity.length() > 0:
		if velocity.x != 0:
			$AnimatedSprite2D.animation = &"right"
			$AnimatedSprite2D.flip_v = false
			$Trail.rotation = 0
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y < 0:
			$AnimatedSprite2D.animation = &"up"
			$Trail.rotation = 0	
		elif velocity.y > 0:
			$AnimatedSprite2D.animation = &"down"
			$Trail.rotation = 0
		
		var change = velocity * delta
		var position_var = get_global_position() + change
		var position_clamped = position_var.clamp(Vector2.ZERO, screen_size)
		
		input_position = position_clamped
		
		$AnimatedSprite2D.play()	
	else:
		$AnimatedSprite2D.stop()

func move_player():
	var latest_input_position = input_position
	
	if player_position != latest_input_position:
		player_position = latest_input_position
		set_global_position(latest_input_position)
		
		emit_signal("send_player_position", latest_input_position)
	

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	
	get_node("../HUD").connect("bot_player_switch", update_bot_mode)
	get_node("../HUD").connect("stop_game", despawn)
	$BotTimer.timeout.connect(update_bot_direction)


func _physics_process(delta):
	handle_input(delta)
	move_player()



