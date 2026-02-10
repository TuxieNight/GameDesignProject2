extends AnimatedSprite2D

var perfect = false
var good = false
var okay = false
var current_note = null

@export var input = ""


func _unhandled_input(event):
	# --- PRESS ---
	if event.is_action_pressed(input, false):
		frame = 1

		if current_note != null:
			if current_note.is_hold:
				# Start holding, DO NOT reset lane state
				current_note.start_hold()
			else:
				print("tap")
				# Tap note scoring
				if perfect:
					print("3")
					get_parent().increment_score(3)
					current_note.destroy(3)
				elif good:
					print("2")
					get_parent().increment_score(2)
					current_note.destroy(2)
				elif okay:
					print("1")
					get_parent().increment_score(1)
					current_note.destroy(1)

				_reset()  # Only reset for tap notes
		else:
			print("0")
			get_parent().increment_score(0)

	# --- RELEASE ---
	if event.is_action_released(input):
		$PushTimer.start()
		frame = 0

		# If we were holding a note, check if we released early
		if current_note != null and current_note.is_hold:
			current_note.release_hold()
			_reset()  # Now we reset after the hold ends


func _on_PerfectArea_area_entered(area):
	if area.is_in_group("note"):
		perfect = true


func _on_PerfectArea_area_exited(area):
	if area.is_in_group("note"):
		perfect = false


func _on_GoodArea_area_entered(area):
	if area.is_in_group("note"):
		good = true


func _on_GoodArea_area_exited(area):
	if area.is_in_group("note"):
		good = false


func _on_OkayArea_area_entered(area):
	if area.is_in_group("note"):
		okay = true
		current_note = area


func _on_OkayArea_area_exited(area):
	if area.is_in_group("note"):
		okay = false
		current_note = null


func _on_PushTimer_timeout():
	frame = 0


func _reset():
	current_note = null
	perfect = false
	good = false
	okay = false
