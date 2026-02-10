extends Area2D

const TARGET_Y = 164
const SPAWN_Y = -16
const DIST_TO_TARGET = TARGET_Y - SPAWN_Y

const LEFT_LANE_SPAWN = Vector2(120, SPAWN_Y)
const CENTRE_LANE_SPAWN = Vector2(160, SPAWN_Y)
const RIGHT_LANE_SPAWN = Vector2(200, SPAWN_Y)

var speed = 0
var hit = false
var hold_duration_beats = 0.0
var hold_end_time = 0.0
var is_hold = false
var is_holding = false
var conductor
var hold_release_window := 0.1
var eval_hold = false


func _ready():
	pass


func _physics_process(delta):
	if !hit:
		position.y += speed * delta
		if position.y > 200:
			queue_free()
			get_parent().reset_combo()
	else:
		$Node2D.position.y -= speed * delta
	if is_hold and is_holding:
		if conductor.song_position >= hold_end_time - hold_release_window && !eval_hold:
			finish_hold()
			print("here")


func initialize(lane, duration_beats, sec_per_beat, spawn_time, conductor_ref):
	conductor = conductor_ref
	hold_duration_beats = duration_beats
	is_hold = duration_beats > 0.0
	if is_hold:
		hold_end_time = spawn_time + duration_beats * sec_per_beat

	if lane == 0:
		$AnimatedSprite.frame = 0
		position = LEFT_LANE_SPAWN
	elif lane == 1:
		$AnimatedSprite.frame = 1
		position = CENTRE_LANE_SPAWN
	elif lane == 2:
		$AnimatedSprite.frame = 2
		position = RIGHT_LANE_SPAWN
	else:
		printerr("Invalid lane set for note: " + str(lane))
		return
	
	speed = DIST_TO_TARGET / 2.0

func start_hold():
	is_holding = true
	hit = true
	$AnimatedSprite.visible = false
	$CPUParticles2D.emitting = true

func finish_hold():
	eval_hold = true
	get_parent().increment_score(3)
	print("finish")
	destroy(3)

func release_hold():
	# If release is close enough to the end, count as success
	if conductor.song_position >= hold_end_time - hold_release_window:
		print("release")
		finish_hold()
		return

	# Otherwise, it's a real fail
	show_label("MISS", Color("ff0000"))
	destroy(0)

func show_label(text, color):
	$Node2D/Label.text = text
	$Node2D/Label.modulate = color
	$AnimatedSprite.visible = false
	$CPUParticles2D.emitting = true

func destroy(score):
	$CPUParticles2D.emitting = true
	$AnimatedSprite.visible = false
	$Timer.start()
	hit = true
	if score == 3:
		$Node2D/Label.text = "GREAT"
		$Node2D/Label.modulate = Color("f6d6bd")
	elif score == 2:
		$Node2D/Label.text = "GOOD"
		$Node2D/Label.modulate = Color("c3a38a")
	elif score == 1:
		$Node2D/Label.text = "OKAY"
		$Node2D/Label.modulate = Color("997577")


func _on_Timer_timeout():
	queue_free()
