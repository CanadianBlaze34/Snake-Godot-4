extends Node2D

@export var cell_size := Vector2(40, 40)

@onready var screen_size := DisplayServer.window_get_size()
@onready var snake_preload := preload("res://Scenes/snake.tscn")
@onready var score_label := $Background/Score
@onready var background := $Background
@onready var HUD := $HUD
@onready var HUD_score := $HUD/Score

var snake : Snake = null
var apple : ColorRect = null
var grid : Grid = null
var cells := Vector2.ZERO
var score := 0

func _ready():
	randomize()
	_instantiate()

func _instantiate() -> void:
	HUD.visible = false
	score_label.visible = true
	_instantiate_snake()
	cells = screen_size / Vector2i(cell_size)
	_instantiate_grid()
	_instantiate_apple()
	_connect_signals()
	background.size = screen_size

func _connect_signals() -> void:
	snake.connect('died', _on_snake_died)

func _disconnect_signals() -> void:
	snake.disconnect('died', _on_snake_died)

func _uninstantiate() -> void:
	_disconnect_signals()
	remove_child(grid)
	grid.queue_free()
	grid = null
	remove_child(apple)
	apple.queue_free()
	apple = null
	remove_child(snake)
	snake.queue_free()
	snake = null

func _process(_delta):
	if not HUD.visible:
		if snake.head_position() == apple.position:
			snake.add_body()
			_increase_score()
			if score == cells.x * cells.y: # maximum cells are taken up
				_set_HUD()
			else:
				_reset_apple_position()

func _set_HUD() -> void:
	_set_score_label_text(HUD_score)
	score_label.visible = false
	HUD.visible = true

func _instantiate_snake() -> void:
	snake = snake_preload.instantiate()
	snake.init(cell_size)
	add_child(snake)

func _instantiate_grid() -> void:
	grid = Grid.new(cell_size, cells, score_label.get_theme_color('font_color'), 1)
	add_child(grid)

func _instantiate_apple() -> void:
	apple = ColorRect.new()
	apple.custom_minimum_size = cell_size
	apple.size = apple.custom_minimum_size
	apple.color = Color('red')
	apple.name = 'Apple'
	_reset_apple_position()
	add_child(apple)

func _reset_apple_position() -> void:
	apple.position = _random_apple_position()

func _random_apple_position() -> Vector2:
	
	var _grid : Array[Vector2] = []
	for y in range(cells.y):
		for x in range(cells.x):
			_grid.append(Vector2(x, y))
	
	var snake_positions := snake.positions()
	# remove all of snake positions in the grid
	for index in range(snake_positions.size()):
		var _position := snake_positions[index]
		var cell_position := _position / cell_size
		_grid.erase(cell_position)
	
	_grid.shuffle()
	var random_index := randi() % _grid.size()
	return _grid[random_index] * cell_size

func _on_snake_died() -> void:
	_set_HUD()
	_uninstantiate()
	_reset_score()
	
func _reset_score() -> void:
	score = 0
	_set_score_label_text(score_label)

func _increase_score() -> void:
	score += 1
	_set_score_label_text(score_label)

func _set_score_label_text(label : Label) -> void:
	label.text = '%03d' % score

func _on_retry_pressed():
	HUD.visible = false
	_set_score_label_text(HUD_score)
	_instantiate()
	
	
	
