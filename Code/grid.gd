extends Node2D

class_name Grid

var color : Color
var width : int
var cell_size : Vector2
var cells : Vector2

func _init(_cell_size := cell_size, _cells := cells, _color := color, _width := width) -> void:
	cell_size = _cell_size
	cells = _cells
	color = _color
	width = _width

func _draw() -> void:	
	# Vertical lines
	for x in range(cells.x):
		var start := Vector2(x * cell_size.x, 0.0)
		var end := Vector2(x * cell_size.x, cells.y * cell_size.y)
		draw_line(start, end, color, width)
	
	# Horizontal lines
	for y in range(cells.y):
		var start := Vector2(0.0, y * cell_size.y)
		var end := Vector2(cells.x * cell_size.x, y * cell_size.y)
		draw_line(start, end, color, width)
