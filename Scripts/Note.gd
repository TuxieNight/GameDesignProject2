extends Area2D

@export var beats_visible := 4.0

# --- HORIZONTAL NOTE HIGHWAY ---
const staffWidth := 200
const staffHeight := 157

var TARGET_X := -10
var DIST_TO_TARGET = staffWidth * 2.5
var SPAWN_X = TARGET_X + DIST_TO_TARGET
var noteY = -staffHeight
var noteSpacing = 19
var note_time

const DURATION_TO_FRAME := {
	1.0: 0,   # quarter
	2.0: 1,   # half
	4.0: 2,   # whole
	0.5: 3,   # eighth
	0.25: 4   # sixteenth
	# special frames will involve +5 (like C4 and A5)
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
var game: Node


func _physics_process(_delta):
	var t = conductor.song_position
	var time_until_hit = note_time - t
	position.x = TARGET_X + time_until_hit * speed
	
	if !hit and time_until_hit < 0:
			queue_free()
			game.reset_combo()

	if is_hold and is_holding:
		if conductor.song_position >= hold_end_time - hold_release_window and !eval_hold:
			finish_hold()


func initialize(gameRef, note_name: String, duration_beats: float, sec_per_beat, spawn_time, conductor_ref, beats_visible_val):
	game = gameRef
	conductor = conductor_ref
	beats_visible = beats_visible_val
	note_time = spawn_time
	
	var travel_time = beats_visible * sec_per_beat
	speed = DIST_TO_TARGET / travel_time

	var STAFF_LANES = {
	"C4": noteSpacing*13 + noteY,
	"D4": noteSpacing*12 + noteY,
	"E4": noteSpacing*11 + noteY,
	"F4": noteSpacing*10 + noteY,
	"G4": noteSpacing*9 + noteY,
	"A4": noteSpacing*8 + noteY,
	"B4": noteSpacing*7 + noteY,
	"C5": noteSpacing*6 + noteY,
	"D5": noteSpacing*5 + noteY,
	"E5": noteSpacing*4 + noteY,
	"F5": noteSpacing*3 + noteY,
	"G5": noteSpacing*2 + noteY,
	"A5": noteSpacing*1 + noteY,
	"B5": noteSpacing*0 + noteY,
	"C6": noteSpacing*-1 + noteY,
	"D6": noteSpacing*-2 + noteY,
	"E6": noteSpacing*-3 + noteY,
	"F6": noteSpacing*-4 + noteY,
	"G6": noteSpacing*-5 + noteY,
	"A6": noteSpacing*-6 + noteY,
	"B6": noteSpacing*-7 + noteY,
	"C7": noteSpacing*-8 + noteY
}

	# HOLD SETUP
	hold_duration_beats = duration_beats
	is_hold = duration_beats > 1.0
	if is_hold:
		hold_end_time = spawn_time + duration_beats * sec_per_beat

	var rounded : float
	rounded = snapped(duration_beats, 0.01)

	# SPRITE FRAME
	if DURATION_TO_FRAME.has(rounded):
		var special = 0
#		if note_name == "C4" or note_name == "A5":
#			special += 5
		$AnimatedSprite.frame = DURATION_TO_FRAME[rounded] + special

	# POSITION
	if STAFF_LANES.has(note_name):
		position = Vector2(SPAWN_X, STAFF_LANES[note_name])
	else:
		printerr("Unknown note: ", note_name)



# --- HOLD LOGIC ---
func start_hold():
	is_holding = true
	hit = true
	$AnimatedSprite.visible = false
	$CPUParticles2D.emitting = true


func finish_hold():
	eval_hold = true
	game.increment_score(3)
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
