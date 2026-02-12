extends Node2D


func _ready():
	$GradeNumber.text = Global.grade
	$ScoreNumber.text = str(Global.score)
	$ComboNumber.text = str(Global.combo)
	$GreatNumber.text = str(Global.great)
	$GoodNumber.text = str(Global.good)
	$OkayNumber.text = str(Global.okay)
	$MissedNumber.text = str(Global.missed)
	


func _unhandled_input(event):
	if event.is_action_pressed("spacebar", false):
		if get_tree().change_scene_to_file("res://Scenes/Menu.tscn") != OK:
			print ("Error changing scene to Menu")
