extends TextEdit
class_name TextInput

@export var numberOfLines : int = 5
@onready var font: Font = get_theme_font("font")
@onready var font_size: int = get_theme_font_size("font_size")

@export var handler : inputHandler

var previousText : String = ""

func _ready() -> void:
	grab_focus()
	text_changed.connect(_text_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == 1 && has_focus() && _is_inside(event):
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("shift_enter") && has_focus():
		var lastLine = get_caret_line()
		insert_text("\n", lastLine, get_caret_column())
		set_caret_line(lastLine + 1)
		set_caret_column(0)
	if event.is_action_pressed("enter") && has_focus():
		handler.send()
		get_viewport().set_input_as_handled()

func _text_changed():
	var lastLine = get_caret_line()
	var lastCol = get_caret_column()
	if get_number_of_lines_used() > 5:
		text = previousText
		set_caret_line(lastLine)
		set_caret_column(lastCol)
	previousText = text

func _is_inside(event: InputEventMouse) -> bool:
	return Rect2(global_position, size).has_point(event.global_position)

func get_number_of_lines_used() -> int:
	if text.strip_escapes().strip_edges().is_empty(): return 0
	var count : int = 0
	for i in get_line_count():
		count += get_line_wrap_count(i)
		count += 1
	return count

func _on_reset_button_up() -> void:
	clear()
