extends Button

@export var toFocus : Control
@export var offset : Vector2 = Vector2.ZERO

func _ready() -> void:
	button_up.connect(_button_up)
	
func _button_up() -> void:
	toFocus.grab_focus()
