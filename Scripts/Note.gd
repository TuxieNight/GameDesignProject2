extends Area2D

# --- HORIZONTAL NOTE HIGHWAY ---
const TARGET_X := 160          # receptor X position
const SPAWN_X := 400           # off-screen to the right
const DIST_TO_TARGET := SPAWN_X - TARGET_X

# Adjust these Y values to match your lane layout
const TOP_LANE_Y := 120
const MID_LANE_Y := 160
const BOT_LANE_Y := 200

const TOP_LANE_SPAWN    := Vector2(SPAWN_X, TOP_LANE_Y)
const MIDDLE_LANE_SPAWN := Vector2(SPAWN_X, MID_LANE_Y)
const BOTTOM_LANE_SPAWN := Vector2(SPAWN_X, BOT_LANE_Y)

var speed := 0.0
var hit := false

# --- HOLD NOTE DATA ---
var hold_duration_beats := 0.0
var hold_end_time := 0.0
var is_hold := false
var is_holding := false
var eval_hold := false
var hold_release_window := 0.1
var initial_hit_score := 0

var conductor


func _physics_process(delta):
	# --- MOVEMENT ---
	if !hit:
		position.x -= speed * delta
		if position.x < TARGET_X:
			queue_free()
			get_parent().reset_combo()
	else:
		$Node2D.position.x -= speed * delta

	# --- HOLD COMPLETION CHECK ---
	if is_hold and is_holding:
		if conductor.song_position >= hold_end_time - hold_release_window and !eval_hold:
			finish_hold()


func initialize(lane, duration_beats, sec_per_beat, spawn_time, conductor_ref):
	conductor = conductor_ref

	# HOLD SETUP
	hold_duration_beats = duration_beats
	is_hold = duration_beats > 0.0
	if is_hold:
		hold_end_time = spawn_time + duration_beats * sec_per_beat

	# --- SPAWN POSITION ---
	match lane:
		0:
			$AnimatedSprite.frame = 0
			position = TOP_LANE_SPAWN
		1:
			$AnimatedSprite.frame = 1
			position = MIDDLE_LANE_SPAWN
		2:
			$AnimatedSprite.frame = 2
			position = BOTTOM_LANE_SPAWN
		_:
			printerr("Invalid lane: ", lane)
			return

	# --- SPEED ---
	speed = DIST_TO_TARGET / 2.0


# --- HOLD LOGIC ---
func start_hold():
	is_holding = true
	hit = true
	$AnimatedSprite.visible = false
	$CPUParticles2D.emitting = true


func finish_hold():
	eval_hold = true
	get_parent().increment_score(3)
	destroy(initial_hit_score)


func release_hold():
	# Released close enough → success
	if conductor.song_position >= hold_end_time - hold_release_window:
		finish_hold()
		return

	# Released too early → MISS
	show_label("MISS", Color("ff0000"))
	destroy(0)


# --- VISUAL FEEDBACK ---
func show_label(text, color):
	$Node2D/Label.text = text
	$Node2D/Label.modulate = color
	$AnimatedSprite.visible = false
	$CPUParticles2D.emitting = true

func register_initial_hit(score):
	initial_hit_score = score

func destroy(score):
	$CPUParticles2D.emitting = true
	$AnimatedSprite.visible = false
	$Timer.start()
	hit = true

	match score:
		3:
			$Node2D/Label.text = "GREAT"
			$Node2D/Label.modulate = Color("f6d6bd")
		2:
			$Node2D/Label.text = "GOOD"
			$Node2D/Label.modulate = Color("c3a38a")
		1:
			$Node2D/Label.text = "OKAY"
			$Node2D/Label.modulate = Color("997577")
		0:
			$Node2D/Label.text = "MISS"
			$Node2D/Label.modulate = Color("ff0000")


func _on_Timer_timeout():
	queue_free()
