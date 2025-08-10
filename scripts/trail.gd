extends Line2D

var queue : Array
@export var MAX_LENGTH : int
@export var main_body : Node2D
var custom_color : Color = Color(0xffffff)
var track : bool = true
func _ready() -> void:
	default_color = custom_color

func _process(_delta):
	if track:
		var pos = _get_position()
		queue.push_front(pos)
		if queue.size() > MAX_LENGTH:
			queue.pop_back()
			
		clear_points()
		for point in queue:
			add_point(point)
	

func _get_position():
	return main_body.global_position

func set_custom_color(col: Color) -> void:
	custom_color = col
	default_color = custom_color

func reset_trail():
	queue.clear()
	clear_points()
