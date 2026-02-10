extends Camera2D

const TRANS := Tween.TRANS_SINE
const EASE := Tween.EASE_IN_OUT

var amplitude: float = 0.0
var priority: int = 0

@onready var duration_timer: Timer = $Duration
@onready var frequency_timer: Timer = $Frequency

func shake(duration: float = 0.2, frequency: float = 15.0, amp: float = 2.0, prio: int = 0) -> void:
	if prio >= priority:
		priority = prio
		amplitude = amp

		duration_timer.wait_time = duration
		frequency_timer.wait_time = 1.0 / frequency

		duration_timer.start()
		frequency_timer.start()

		_shake()


func _shake() -> void:
	var rand := Vector2(
		randf_range(-amplitude, amplitude),
		randf_range(-amplitude, amplitude)
	)

	var tween := create_tween()
	tween.tween_property(self, "offset", rand, frequency_timer.wait_time).set_trans(TRANS).set_ease(EASE)


func _on_Frequency_timeout() -> void:
	_shake()


func _reset() -> void:
	var tween := create_tween()
	tween.tween_property(self, "offset", Vector2.ZERO, frequency_timer.wait_time).set_trans(TRANS).set_ease(EASE)
	priority = 0


func _on_Duration_timeout() -> void:
	_reset()
	frequency_timer.stop()
