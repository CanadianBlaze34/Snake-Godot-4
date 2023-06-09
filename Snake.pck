GDPC                 �                                                                         T   res://.godot/exported/133200997/export-0271e18ecf37a36b455ad0b215994549-world.scn   ,            ��IW�wD6��SV��    T   res://.godot/exported/133200997/export-87c4d43ea973d291e4e46a154cb5153f-snake.scn   �(      &      QBM��j�=�B]    P   res://.godot/exported/133200997/export-c1b0c2b93b5bb5c3a9c4422242e11233-grid.scnp&      l      b���5�@��cK��l    ,   res://.godot/global_script_class_cache.cfg          �       �zi�u��y#|>��    D   res://.godot/imported/icon.png-b9450fb2459f5b277908511db3d050dd.ctex #      �       �>��It��B �SMd    D   res://.godot/imported/icon.svg-40d11009b022ae281956dc38e8f8d85e.ctex�$      *      �a�bk���y#�P       res://.godot/uid_cache.bin  `@      �       �S��W*L�L�2�5��       res://Code/grid.gd         �      �8g|w�ȉO`�ժ       res://Code/main.gd  �      g      ��s��{���;�c��       res://Code/snake.gd        �      �<���U�+��1�W       res://Scenes/grid.tscn.remap03      a       U����7�*Z�[-        res://Scenes/snake.tscn.remap   �3      b       �𱂐��z�
��H
        res://Scenes/world.tscn.remap   4      b        �!�I��)%�a�       res://images/icon.png.import�#      �       |^��,j�����u"H       res://images/icon.svg   �4      �      qp��鴟���Y�W��       res://images/icon.svg.import�%      �       �h�](�&6�3Œ       res://project.binaryA      �      ��rrGT��I҄�    list=Array[Dictionary]([{
"base": &"Node2D",
"class": &"Grid",
"icon": "",
"language": &"GDScript",
"path": "res://Code/grid.gd"
}, {
"base": &"Node2D",
"class": &"Snake",
"icon": "",
"language": &"GDScript",
"path": "res://Code/snake.gd"
}])
�w��.��5|�ץextends Node2D

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
	]�extends Node2D

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



���WT�n]extends Node2D

class_name Snake

@export var color := Color(0.0, 1.0, 0.0)

@onready var move_delay := $"move delay"

var sprite_size : Vector2
var initial_position : Vector2
var screen_size := DisplayServer.window_get_size()
var last_direction := Vector2.ZERO
var moved_since_new_direction := true
var sprites : Array[ColorRect] = []
var _add_body := 0

const HEAD : int = 0

signal died

func init(_sprite_size := sprite_size) -> void:
	sprite_size = _sprite_size
	initial_position = ((screen_size / Vector2i(sprite_size)) / 2) * Vector2i(sprite_size)
	_reset()

func _reset() -> void:
	_reset_direction()
	_reset_sprites()
	moved_since_new_direction = true

func _move() -> void:
	
	# create a new color rect at the position the head should go
	var new_head := _create_color_rect('Head', get_head().position + last_direction * sprite_size)
	sprites.insert(0, new_head)
	# remove the oldest color rect when not adding a body
	if _add_body != 0:
		_add_body -= 1
	else:
		var last_index := sprites.size() - 1
		remove_child(sprites[last_index])
		sprites.remove_at(last_index)
	
	for index in range(sprites.size() - 1):
		var sprite := sprites[index + 1]
		sprite.name = 'body ' + str(index)
	
	moved_since_new_direction = true
	
	if _off_screen() or _hit_self():
		_reset()
		died.emit()

func _hit_self() -> bool:
	var head := get_head()
	# loop through everything but the first element
	for index in range(sprites.size() - 1):
		var body := sprites[index + 1]
		if head.position == body.position:
			return true
	return false

func _off_screen() -> bool:
	var head := get_head()
	return head.position.x + sprite_size.x > screen_size.x \
	or head.position.y + sprite_size.y > screen_size.y \
	or head.position.x < 0 \
	or head.position.y < 0

func get_head() -> ColorRect:
	return sprites[HEAD]

func _reset_direction() -> void:
	last_direction = Vector2.ZERO

func _reset_sprites() -> void:
	_remove_sprites()
	sprites.clear()
	sprites.append(_create_head())
	pass

func _remove_sprites() -> void:
	for sprite in sprites:
		remove_child(sprite)
		sprite.queue_free()

func _create_head() -> ColorRect:
	return _create_color_rect('Head', initial_position)

func _change_direction(direction) -> void:
	# has moved onced last frame
	# has moved in a new direction 
	# that isn't the oppisite of the current direction
	if moved_since_new_direction \
		and direction != null \
		and direction != last_direction \
		and direction != -last_direction:
		moved_since_new_direction = false
		last_direction = direction

func _unhandled_key_input(event) -> void:
	var direction = null
	
	if   event.is_action_pressed("ui_up")    : direction = Vector2.UP
	elif event.is_action_pressed("ui_down")  : direction = Vector2.DOWN
	elif event.is_action_pressed("ui_right") : direction = Vector2.RIGHT
	elif event.is_action_pressed("ui_left")  : direction = Vector2.LEFT
	
	_change_direction(direction)

func _on_move_delay_timeout() -> void:
	_move()

func _create_color_rect(_name : String, _position : Vector2) -> ColorRect:
	var color_rect := ColorRect.new()
	color_rect.custom_minimum_size = sprite_size
	color_rect.size = color_rect.custom_minimum_size
	color_rect.color = color
	color_rect.name = _name
	color_rect.position = _position
	add_child(color_rect)
	return color_rect

func add_body(increment : int) -> void:
	_add_body = increment

func positions() -> Array[Vector2]:
	var _positions : Array[Vector2] = []
	for sprite in sprites:
		_positions.append(sprite.position)
	return _positions

func head_position() -> Vector2:
	return get_head().position
�GST2   �   �      ����               � �        z   RIFFr   WEBPVP8Le   /��1 H�}�љ]A����Aq�6NʌwCz��u��.��"�m��9�Li�h(T,>W�]�Ma�͛�Ka�pޥ67o��6�O	���� D
� ��Q��Re��̀��0[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://g1lpcgxyejhu"
path="res://.godot/imported/icon.png-b9450fb2459f5b277908511db3d050dd.ctex"
metadata={
"vram_texture": false
}
 GST2   �   �      ����               � �        �   RIFF�   WEBPVP8L�   /��1W���$h��[�l�qp�l(n#�����w
F�F*>�������,C",�
O�x����m�Mϝ$>k� �  n�Q���iu ���	p(���@7`��*�'��I���(d���}�a�<���	-?�	�(R�$�G$UJ='�9!|=���#���Zr_��sB(�E�S��A{�n��'�VQ$ͪ.sB�zjVӥ���;t�����P���s�>�U����[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://sg4jv6jbhqd"
path="res://.godot/imported/icon.svg-40d11009b022ae281956dc38e8f8d85e.ctex"
metadata={
"vram_texture": false
}
 �RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://Code/grid.gd ��������      local://PackedScene_qkf8w 
         PackedScene          	         names "         grid    script    Node2D    	   variants                       node_count             nodes     	   ��������       ����                    conn_count              conns               node_paths              editable_instances              version             RSRCz}5RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://Code/snake.gd ��������      local://PackedScene_ivjkp          PackedScene          	         names "   	      Snake    script    Node2D    move delay 
   wait_time 
   autostart    Timer    _on_move_delay_timeout    timeout    	   variants                 )   333333�?            node_count             nodes        ��������       ����                            ����                         conn_count             conns                                      node_paths              editable_instances              version             RSRCYx{��8߼�RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://Code/main.gd ��������      local://PackedScene_78r24 
         PackedScene          	         names "         World    script 
   cell_size    Node2D    Background    z_index    offset_right    offset_bottom    color 
   ColorRect    Score    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical !   theme_override_colors/font_color $   theme_override_font_sizes/font_size    text    horizontal_alignment    vertical_alignment    Label    HUD    visible    retry    offset_left    offset_top    Button    _on_retry_pressed    pressed    	   variants                 
     �B  �B   ����     �D     4D   ���>��?��I?  �?                 �?         ��h>	��>��;?  �?           000                       ���>    � D     �C    � �     �   4         Retry       node_count             nodes     �   ��������       ����                            	      ����                                         
   ����                              	      	      
                                       	      ����                                         
   ����                              	      	      
                                            ����                                                      	      	      
                         conn_count             conns                                      node_paths              editable_instances              version             RSRCH��-[remap]

path="res://.godot/exported/133200997/export-c1b0c2b93b5bb5c3a9c4422242e11233-grid.scn"
0+K3���B�y�4[remap]

path="res://.godot/exported/133200997/export-87c4d43ea973d291e4e46a154cb5153f-snake.scn"
�H%C?{-3
�Lp�[remap]

path="res://.godot/exported/133200997/export-0271e18ecf37a36b455ad0b215994549-world.scn"
% �e����y�<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="241px" height="200px" style="shape-rendering:geometricPrecision; text-rendering:geometricPrecision; image-rendering:optimizeQuality; fill-rule:evenodd; clip-rule:evenodd" xmlns:xlink="http://www.w3.org/1999/xlink">
<g><path style="opacity:1" fill="#3a7cbb" d="M -0.5,-0.5 C -0.166667,-0.5 0.166667,-0.5 0.5,-0.5C 0.5,12.5 0.5,25.5 0.5,38.5C 13.5,38.5 26.5,38.5 39.5,38.5C 39.5,25.5 39.5,12.5 39.5,-0.5C 39.8333,-0.5 40.1667,-0.5 40.5,-0.5C 40.5,25.8333 40.5,52.1667 40.5,78.5C 67.1667,78.5 93.8333,78.5 120.5,78.5C 120.5,105.167 120.5,131.833 120.5,158.5C 160.5,158.5 200.5,158.5 240.5,158.5C 240.5,172.167 240.5,185.833 240.5,199.5C 186.833,199.5 133.167,199.5 79.5,199.5C 79.5,172.833 79.5,146.167 79.5,119.5C 52.8333,119.5 26.1667,119.5 -0.5,119.5C -0.5,79.5 -0.5,39.5 -0.5,-0.5 Z"/></g>
<g><path style="opacity:1" fill="#00ff00" d="M 0.5,-0.5 C 13.5,-0.5 26.5,-0.5 39.5,-0.5C 39.5,12.5 39.5,25.5 39.5,38.5C 26.5,38.5 13.5,38.5 0.5,38.5C 0.5,25.5 0.5,12.5 0.5,-0.5 Z"/></g>
<g><path style="opacity:1" fill="#00ff00" d="M 0.5,39.5 C 13.5,39.5 26.5,39.5 39.5,39.5C 39.5,52.5 39.5,65.5 39.5,78.5C 26.5,78.5 13.5,78.5 0.5,78.5C 0.5,65.5 0.5,52.5 0.5,39.5 Z"/></g>
<g><path style="opacity:1" fill="#00ff00" d="M 0.5,79.5 C 13.5,79.5 26.5,79.5 39.5,79.5C 39.5,92.5 39.5,105.5 39.5,118.5C 26.5,118.5 13.5,118.5 0.5,118.5C 0.5,105.5 0.5,92.5 0.5,79.5 Z"/></g>
<g><path style="opacity:1" fill="#00ff00" d="M 40.5,79.5 C 53.5,79.5 66.5,79.5 79.5,79.5C 79.5,92.5 79.5,105.5 79.5,118.5C 66.5,118.5 53.5,118.5 40.5,118.5C 40.5,105.5 40.5,92.5 40.5,79.5 Z"/></g>
<g><path style="opacity:1" fill="#00ff00" d="M 80.5,79.5 C 93.5,79.5 106.5,79.5 119.5,79.5C 119.5,92.5 119.5,105.5 119.5,118.5C 106.5,118.5 93.5,118.5 80.5,118.5C 80.5,105.5 80.5,92.5 80.5,79.5 Z"/></g>
<g><path style="opacity:1" fill="#00ff00" d="M 80.5,119.5 C 93.5,119.5 106.5,119.5 119.5,119.5C 119.5,132.5 119.5,145.5 119.5,158.5C 106.5,158.5 93.5,158.5 80.5,158.5C 80.5,145.5 80.5,132.5 80.5,119.5 Z"/></g>
<g><path style="opacity:1" fill="#00ff00" d="M 80.5,159.5 C 93.5,159.5 106.5,159.5 119.5,159.5C 119.5,172.5 119.5,185.5 119.5,198.5C 106.5,198.5 93.5,198.5 80.5,198.5C 80.5,185.5 80.5,172.5 80.5,159.5 Z"/></g>
<g><path style="opacity:1" fill="#00ff00" d="M 120.5,159.5 C 133.5,159.5 146.5,159.5 159.5,159.5C 159.5,172.5 159.5,185.5 159.5,198.5C 146.5,198.5 133.5,198.5 120.5,198.5C 120.5,185.5 120.5,172.5 120.5,159.5 Z"/></g>
<g><path style="opacity:1" fill="#00ff00" d="M 160.5,159.5 C 173.5,159.5 186.5,159.5 199.5,159.5C 199.5,172.5 199.5,185.5 199.5,198.5C 186.5,198.5 173.5,198.5 160.5,198.5C 160.5,185.5 160.5,172.5 160.5,159.5 Z"/></g>
<g><path style="opacity:1" fill="#00ff00" d="M 200.5,159.5 C 213.5,159.5 226.5,159.5 239.5,159.5C 239.5,172.5 239.5,185.5 239.5,198.5C 226.5,198.5 213.5,198.5 200.5,198.5C 200.5,185.5 200.5,172.5 200.5,159.5 Z"/></g>
</svg>
���]�s�   ����@R�   res://images/icon.pngw$L��~�    res://images/icon.svg�IW���   res://Scenes/grid.tscn����5   res://Scenes/snake.tscn����D�Q   res://Scenes/world.tscnQECFG      application/config/name         Snake      application/run/main_scene          res://Scenes/world.tscn    application/config/features$   "         4.0    Forward Plus       application/config/icon          res://images/icon.svg   "   display/window/size/viewport_width         #   display/window/size/viewport_height      �     display/window/stretch/mode         canvas_items   input/ui_left�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode     @    physical_keycode       	   key_label             unicode     @    echo          script            InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index         pressure          pressed           script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   A   	   key_label             unicode    a      echo          script         input/ui_right�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode     @    physical_keycode       	   key_label             unicode     @    echo          script            InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index         pressure          pressed           script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   D   	   key_label             unicode    d      echo          script         input/ui_up�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode     @    physical_keycode       	   key_label             unicode     @    echo          script            InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index         pressure          pressed           script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W   	   key_label             unicode    w      echo          script         input/ui_down�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode     @    physical_keycode       	   key_label             unicode     @    echo          script            InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index         pressure          pressed           script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S   	   key_label             unicode    s      echo          script      =�