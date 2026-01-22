@tool
extends TextureRect

var tween : Tween
var hover : bool = false

func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	gui_input.connect(_gui_input)

func _mouse_entered() -> void:
	hover = true
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _mouse_exited() -> void:
	hover = false
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _pressed() -> void:
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
	if hover:
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	else:
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_mask == 1 && not event.is_echo():
		if event.pressed:
			_pressed()
