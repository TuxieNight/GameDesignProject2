extends Area2D

@export var beats_visible := 4.0

const staffWidth := 200
const staffHeight := 157

var TARGET_X := -1.0
var DIST_TO_TARGET = staffWidth * 5.0
var ORIGINAL_SPAWN_X = TARGET_X + DIST_TO_TARGET
var VISIBLE_DIST = TARGET_X + staffWidth * 2.5

var noteY = -staffHeight
var noteSpacing = 19
var note_time

const DURATION_NAME_TO_FRAME := {
	"quarter": 0,
	"half": 1,
	"whole": 2,
	"eighth": 3,
	"sixteenth": 4,
	"dotted-quarter": 5,
	"dotted-half": 6,
	"dotted-eighth": 7
}

var speed := 0.0
var hit := false

var hold_end_time := 0.0
var is_hold := false
var is_holding := false
var eval_hold := false
var initial_hit_score := 0

var game: Node


func _physics_process(_delta):
	var t = game.song_time
	var time_until_hit = note_time - t

	# PURE ORIGINAL MOVEMENT
	position.x = TARGET_X + time_until_hit * speed

	# Become visible when entering spawn zone
	visible = position.x <= VISIBLE_DIST

	# Miss
	if !hit and time_until_hit < 0:
		queue_free()
		game.reset_combo()

	# Hold end
	if is_hold and is_holding and t >= hold_end_time and !eval_hold:
		finish_hold()


# --- helpers ---

func _normalize(note_name: String) -> String:
	var letter := note_name.rstrip("0123456789")
	var octave := note_name.substr(letter.length())
	if letter.ends_with("#") or letter.ends_with("b"):
		letter = letter.substr(0, letter.length() - 1)
	return letter + octave

func _accidental(note_name: String) -> String:
	var letter := note_name.rstrip("0123456789")
	if letter.ends_with("#"): return "\u266F"
	if letter.ends_with("b"): return "\u266D"
	return ""


func initialize(
		gameRef,
		note_name: String,
		duration_beats: float,
		duration_name: String,
		sec_per_beat,
		spawn_time,
		beats_visible_val,
		note_index
	):
	game = gameRef
	beats_visible = beats_visible_val
	note_time = spawn_time

	# ORIGINAL SPEED CALCULATION
	var travel_time = beats_visible * sec_per_beat
	speed = DIST_TO_TARGET / travel_time

	# STAFF LANES (your calculated version)
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
	is_hold = duration_beats > 1.0
	if is_hold:
		hold_end_time = spawn_time + duration_beats * sec_per_beat

	# SPRITE FRAME
	if DURATION_NAME_TO_FRAME.has(duration_name):
		$AnimatedSprite.frame = DURATION_NAME_TO_FRAME[duration_name]

	# POSITION (original)
	var lane_y = STAFF_LANES[_normalize(note_name)]
	
	# LANE OFFSET PER NOTE (purely visual spacing)
	var lane_offset_amount := 1000.0   # tweak this visually
	DIST_TO_TARGET *= (note_index+1) * lane_offset_amount

	position = Vector2(DIST_TO_TARGET, lane_y)
	visible = false

	# ACCIDENTAL
	var acc = _accidental(note_name)
	$Accidental.text = acc
	$Accidental.visible = acc != ""


# HOLD LOGIC
func start_hold():
	is_holding = true
	hit = true
	$AnimatedSprite.visible = false
	$Accidental.visible = false
	$CPUParticles2D.emitting = true

func finish_hold():
	eval_hold = true
	game.increment_score(3)
	destroy(initial_hit_score)

func release_hold():
	if game.song_time >= hold_end_time:
		finish_hold()
	else:
		show_label("MISS", Color.RED)
		destroy(0)


# FEEDBACK
func show_label(text, color):
	$Node2D/Label.text = text
	$Node2D/Label.modulate = color
	$AnimatedSprite.visible = false
	$Accidental.visible = false
	$CPUParticles2D.emitting = true

func register_initial_hit(score):
	initial_hit_score = score

func destroy(score):
	hit = true
	$AnimatedSprite.visible = false
	$Accidental.visible = false
	$CPUParticles2D.emitting = true
	$Timer.start()

	match score:
		3: $Node2D/Label.text = "GREAT"
		2: $Node2D/Label.text = "GOOD"
		1: $Node2D/Label.text = "OKAY"
		0: $Node2D/Label.text = "MISS"

func _on_Timer_timeout():
	queue_free()
