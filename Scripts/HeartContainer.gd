extends HBoxContainer

@export var max_hearts: int = 5
var current_health: int = max_hearts

var hearts: Array = []
@export var heart_scene: PackedScene

func _ready():
	create_hearts()

func create_hearts():
	# Clear old hearts if reloading
	for child in get_children():
		child.queue_free()

	hearts.clear()

	# Create hearts left → right
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
