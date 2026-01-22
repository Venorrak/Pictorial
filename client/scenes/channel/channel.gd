extends Label
class_name channelLabel

signal _select(emitter: Label)

var _theme : StyleBoxTexture
var selected : bool = false:
	set(value):
		selected = value
		if is_node_ready():
			if selected:
				_selected()
				_select.emit(self)
			else:
				_unselect()

func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	_theme = get("theme_override_styles/normal") as StyleBoxTexture
	_unselect()
	
func _mouse_entered() -> void:
	if not selected:
		modulate.v = 0.9
		_theme.modulate_color.v = 0.8
	
func _mouse_exited() -> void:
	if not selected:
		_theme.modulate_color.v = 1
		modulate.v = 0.7

func _selected() -> void:
	_theme.modulate_color.v = 1
	modulate.v = 1

func _unselect() -> void:
	_mouse_exited()
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_mask == 1 && not event.is_echo():
		if event.pressed:
			selected = !selected
