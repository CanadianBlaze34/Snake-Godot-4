extends Node2D

class_name Snake

@export var color := Color(0.0, 1.0, 0.0)

@onready var move_delay := $"move delay"

var sprite_size : Vector2
var initial_position : Vector2
var screen_size := DisplayServer.window_get_size()
var last_direction := Vector2.ZERO
var moved_since_new_direction := true
var sprites : Array[ColorRect] = []
var _add_body := false

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
	if _add_body:
		_add_body = false
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

func add_body() -> void:
	_add_body = true

func positions() -> Array[Vector2]:
	var _positions : Array[Vector2] = []
	for sprite in sprites:
		_positions.append(sprite.position)
	return _positions

func head_position() -> Vector2:
	return get_head().position
