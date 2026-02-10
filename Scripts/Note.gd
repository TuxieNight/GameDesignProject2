extends Area2D

# --- HORIZONTAL NOTE HIGHWAY ---
const TARGET_X := 160
const SPAWN_X := 400
const DIST_TO_TARGET := SPAWN_X - TARGET_X

# --- TREBLE STAFF LANES (adjust Y values to match your scene) ---
const STAFF_LANES := {
	"E4": 240,
	"F4": 220,
	"G4": 200,
	"A4": 180,
	"B4": 160,
	"C5": 140,
	"D5": 120,
	"E5": 100,
	"F5":  80
}
const DURATION_TO_FRAME := {
	1.0: 0,   # quarter
	2.0: 1,   # half
	4.0: 2,   # whole
	0.5: 3,   # eighth
	0.25: 4   # sixteenth
}

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
	if !hit:
		position.x -= speed * delta
		if position.x < TARGET_X:
			queue_free()
			get_parent().reset_combo()
	else:
		$Node2D.position.x -= speed * delta

	if is_hold and is_holding:
		if conductor.song_position >= hold_end_time - hold_release_window and !eval_hold:
			finish_hold()


func initialize(note_name: String, duration_beats: float, sec_per_beat, spawn_time, conductor_ref):
	conductor = conductor_ref

	# HOLD SETUP
	hold_duration_beats = duration_beats
	is_hold = duration_beats > 1.0   # or however you define holds
	if is_hold:
		hold_end_time = spawn_time + duration_beats * sec_per_beat

	# --- SET SPRITE BASED ON DURATION ---
	if DURATION_TO_FRAME.has(duration_beats):
		$AnimatedSprite.frame = DURATION_TO_FRAME[duration_beats]
	else:
		printerr("Unknown duration: ", duration_beats)

	# --- SET POSITION BASED ON NOTE NAME ---
	if STAFF_LANES.has(note_name):
		position = Vector2(SPAWN_X, STAFF_LANES[note_name])
	else:
		printerr("Unknown note name: ", note_name)

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
	if conductor.song_position >= hold_end_time - hold_release_window:
		finish_hold()
		return

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
