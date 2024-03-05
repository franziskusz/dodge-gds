extends RigidBody2D

const INITIAL_FORCE_DIVISOR: float = 35.0
const AIMING_FORCE_DIVISOR: float = 5.0

var min_speed: float = 150.0
var max_speed: float = 250.0
var direction: float = 0.0
var speed: float = 0.0
var velocity: Vector2 = Vector2(0.0, 0.0)
var target: Vector2 = Vector2(0.0, 0.0)
var aiming_direction: Vector2 = Vector2(0.0, 0.0)
var initial_direction: Vector2 = Vector2(0.0, 0.0)
var has_weight: bool = false
var weight: float = 50.0

signal despawned() #deprecated

func set_weight(has_weight_arg: bool, weight_arg: float):
	has_weight = has_weight_arg
	weight = weight_arg

func _on_VisibilityNotifier2D_screen_exited():
	aim_at_player()
	#queue_free()

func on_start_game(): #deprecated
	queue_free()

func update_target(player_position: Vector2):
	target = player_position
	update_aiming_direction()

func update_aiming_direction():
	var direction_var = get_position().angle_to_point(target)
	aiming_direction = Vector2(speed, 0.0).rotated(direction_var)

func aim_at_player():
	var target_var = target
	look_at(target_var)
	var direction_var = get_position().angle_to_point(target)

	velocity = Vector2(speed, 0.0).rotated(direction_var)
	var velocity_var = velocity
	set_linear_velocity(velocity_var)

	aiming_direction = velocity_var
	initial_direction = velocity_var

func on_game_over_despawn():
	queue_free()

#derived from:
#https://github.com/extrawurst/godot-rust-benchmark/tree/main
func lift_weight():
	var radius: float = 10.0
	var count = int(weight)
	var countf = weight
	var weight_direction = aiming_direction

	for n in range(count):
		var x = sin(n/countf * 360.0)*radius
		var y = cos(n/countf * 360.0)*radius
		var weight_target = Vector2(x,y)*weight_direction / 30.0
		draw_line(Vector2(0.0, 0.0), weight_target, Color(0.7, 0.2, 0.0, 0.5), 1,false)

func _ready():
	$AnimatedSprite2D.play()
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()

	get_node("../Player").send_player_position.connect(update_target)
	get_node("../HUD").stop_game.connect(on_game_over_despawn)

	get_node("../HUD").start_game.connect(on_start_game)

	get_node("..").send_weight.connect(set_weight)

	var target_var = get_node("../Player").get_position()
	target = target_var

	speed = randf_range(min_speed, max_speed)

	aim_at_player()

func _physics_process(_delta):
	var initial_force_divisor = Vector2(INITIAL_FORCE_DIVISOR, INITIAL_FORCE_DIVISOR)
	var aiming_force_divisor = Vector2(AIMING_FORCE_DIVISOR, AIMING_FORCE_DIVISOR)
	var aiming_direction_var = aiming_direction / aiming_force_divisor
	apply_force(aiming_direction_var)
	var initial_direction_var = initial_direction / initial_force_divisor
	apply_force(initial_direction_var)

func _integrate_forces(_state):
	var target_var = target
	look_at(target_var)


func _process(_delta):
	if has_weight:
		queue_redraw()

func _draw():
	if has_weight:
		lift_weight()
