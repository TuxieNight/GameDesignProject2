extends HBoxContainer

var max_hearts: int
var current_health: int

var hearts: Array = []
@export var heart_scene: PackedScene

func initialize(max_hearts_value: int, health_value: int):
	max_hearts = max_hearts_value
	current_health = clamp(health_value, 0, max_hearts)
	create_hearts()

func create_hearts():
	for child in get_children():
		child.queue_free()

	hearts.clear()

	for i in range(max_hearts):
		var heart = heart_scene.instantiate()
		add_child(heart)
		hearts.append(heart)

	update_hearts()

func set_health(value: int):
	current_health = clamp(value, 0, max_hearts)
	update_hearts()

func update_hearts():
	for i in range(max_hearts):
		var heart = hearts[i]
		if i < current_health:
			heart.set_full()
		else:
			heart.set_empty()
