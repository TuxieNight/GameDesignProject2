extends Node2D

func _unhandled_input(event):
	if event.is_action_pressed("spacebar", false):
		if get_tree().change_scene_to_file("res://Scenes/Song1.tscn") != OK:
			print ("Error changing scene to Game")
 
