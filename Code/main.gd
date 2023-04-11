extends Node2D

@export var cell_size := Vector2(40, 40)

@onready var screen_size := DisplayServer.window_get_size()
@onready var snake_preload := preload("res://Scenes/snake.tscn")
@onready var score_label := $Background/Score
@onready var background := $Background
@onready var HUD := $HUD
@onready var HUD_score := $HUD/Score

var snake : Snake = null
const ORANGE_SPAWN : int = 10
var grid  : Grid = null
var cells := Vector2.ZERO
var score := 0
var fruits : Array[ColorRect]

func _ready():
	randomize()
	_instantiate()

func _instantiate() -> void:
	fruits = []
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
	#remove_child(apple)
	#apple.queue_free()
	#apple = null
	remove_child(snake)
	snake.queue_free()
	snake = null
	for fruit in fruits:
		remove_child(fruit)
		fruit.queue_free()
		fruit = null
	fruits.clear()

func _process(_delta):
	if not HUD.visible:
		for index in range(fruits.size()):
			var fruit := fruits[index]
			if snake.head_position() == fruit.position:
				var score_increment := index + 1
				_increase_score(score_increment)
				if score == cells.x * cells.y: # maximum cells are taken up
					_set_HUD()
					return
				else:
					if index == 0: # apple
						if score == ORANGE_SPAWN:
							_instantiate_orange()
						if fruits.size() >= 2: # orange has been instantiated
							var orange := fruits[1]
							_reset_fruits_position(fruit, [orange])
						else: 
							_reset_fruits_position(fruit, [])
							
					elif index == 1: # orange:
						var apple := fruits[0]
						_reset_fruits_position(fruit, [apple])
					return

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
	grid.name = 'Grid'
	add_child(grid)

func _instantiate_apple() -> void:
	_instantiate_fruit(Color('red'), 'Apple', [])

func _instantiate_orange() -> void:
	_instantiate_fruit(Color('FF7C1E'), 'Orange', [fruits[0]])

func _instantiate_fruit(_color : Color, _name : String, fruits_to_remove_position : Array[ColorRect]) -> void:
	var fruit = ColorRect.new()
	fruit.custom_minimum_size = cell_size
	fruit.size = fruit.custom_minimum_size
	fruit.color = _color
	fruit.name = _name
	_reset_fruits_position(fruit, fruits_to_remove_position)
	fruits.append(fruit)
	add_child(fruit)

func _reset_fruits_position(fruit : ColorRect, fruits_to_remove : Array[ColorRect]) -> void:
	fruit.position = _random_fruit_positions(fruits_to_remove)

func _random_fruit_positions(fruits_to_remove : Array[ColorRect]) -> Vector2:
	
	# make the grid
	var _grid : Array[Vector2] = []
	for y in range(cells.y):
		for x in range(cells.x):
			_grid.append(Vector2(x, y))
	
	# remove snake positions
	var snake_positions := snake.positions()
	# remove all of snake positions in the grid
	for index in range(snake_positions.size()):
		var _position := snake_positions[index]
		var cell_position := _position / cell_size
		_grid.erase(cell_position)
	
	# remove fruits positions
	# remove all of fruits positions in the grid
	for index in range(fruits_to_remove.size()):
		var _position := fruits_to_remove[index].position
		var cell_position := _position / cell_size
		_grid.erase(cell_position)
	
	# generate the random position for the fruit
	_grid.shuffle()
	var random_index := randi() % _grid.size()
	var random_position := _grid[random_index] * cell_size
	
	return random_position

func _on_snake_died() -> void:
	_set_HUD()
	_uninstantiate()
	_reset_score()
	
func _reset_score() -> void:
	score = 0
	_set_score_label_text(score_label)

func _increase_score(increment : int) -> void:
	snake.add_body(increment)
	score += increment
	_set_score_label_text(score_label)

func _set_score_label_text(label : Label) -> void:
	label.text = '%03d' % score

func _on_retry_pressed():
	HUD.visible = false
	_set_score_label_text(HUD_score)
	_instantiate()



