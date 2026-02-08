extends TextureRect
class_name CanvasInput

@export var textEdit : TextEdit
var currentImg : Image
var brushSize : int = 3
var brushColor : Color = Color.BLACK

func _ready() -> void:
	_reset()

func _input(event: InputEvent) -> void:
	var globalposition : Vector2 = get_global_rect().position
	if event is InputEventMouse && _is_inside(globalposition, event) && (event.button_mask == 1 || event.button_mask == 2) && not event.is_echo():
		textEdit.grab_focus()
		var cursorPosition : Vector2 = Vector2(event.global_position - globalposition)
		if event is InputEventMouseMotion:
			if event.relative.length_squared() > 0:
				var n : int = ceili(event.relative.length())
				var lastPos : Vector2 = cursorPosition - event.relative
				for i in n:
					cursorPosition = cursorPosition.move_toward(lastPos, 1.0)
					if event.button_mask == 1:
						_brush_at(cursorPosition)
					elif event.button_mask == 2:
						_erase_at(cursorPosition)
				texture.update(currentImg)
		if event is InputEventMouseButton:
			if event.button_mask == 1:
				_brush_at(cursorPosition)
			elif event.button_mask == 2:
				_erase_at(cursorPosition)
			texture.update(currentImg)
			
		

func _brush_at(_position: Vector2) -> void:
	currentImg.fill_rect(Rect2(_position_relative_to_size(_position), Vector2(1, 1)).grow(brushSize), brushColor)

func _erase_at(_position: Vector2) -> void:
	currentImg.fill_rect(Rect2(_position_relative_to_size(_position), Vector2(1, 1)).grow(brushSize), Color.TRANSPARENT)

func _position_relative_to_size(_position: Vector2) -> Vector2:
	return Vector2(
		(_position.x * 468) / size.x,
		(_position.y * 170) / size.y
	)

func _is_inside(_globalPosition: Vector2, event: InputEventMouse) -> bool:
	return Rect2(_globalPosition, size).has_point(event.global_position)

func get_number_of_lines_used() -> int:
	var lineHeight : float = currentImg.get_height() / 5.0
	var lowestY : int = currentImg.get_used_rect().position.y + currentImg.get_used_rect().size.y
	if currentImg.is_invisible() or currentImg.is_empty() : return 0
	return clamp((lowestY / lineHeight) + 1, 1, 5)
	
func get_lines(nbOfLines: int) -> Image:
	@warning_ignore("narrowing_conversion")
	return currentImg.get_region(Rect2i(0, 0, currentImg.get_width(),(currentImg.get_height() / 5.0) * nbOfLines))

func _reset() -> void:
	texture = ImageTexture.create_from_image(Image.create_empty(468, 170, false, Image.FORMAT_RGBA8))
	currentImg = texture.get_image()

func _on_color_picker_button_color_changed(_color: Color) -> void:
	brushColor = _color

func _on_v_slider_value_changed(value: float) -> void:
	@warning_ignore("narrowing_conversion")
	brushSize = value
