extends HBoxContainer

var nbOfLines : int
var text : String
var drawing : Image
var tween : Tween
var id : int
var user : Dictionary

@export var sprites : Array[Texture2D]
@export var bg : TextureRect
@export var canvas : TextureRect
@export var label : Label
@export var menuButton: MenuButton
var popup : PopupMenu

var fontSizeRef : PackedInt32Array = [35, 39, 43, 47, 51]
var lineSpacingRef : PackedInt32Array = [6, 7, 8, 9, 9]
var targetPosition: Vector2

var sizeNbLines : Dictionary = {
	1: 34,
	2: 68,
	3: 102,
	4: 136,
	5: 170
}

func _ready() -> void:
	Backend.logged_in.connect(func(): menuButton.visible = Backend.is_admin() or user['id'] == Backend.user["id"])
	popup = menuButton.get_popup()
	popup.index_pressed.connect(_menu_option_seleted)
	
	bg.texture = sprites[nbOfLines - 1]
	if drawing:
		canvas.texture = ImageTexture.create_from_image(drawing)
	else:
		canvas.custom_minimum_size = Vector2(468, sizeNbLines[nbOfLines])
	
	label.text = text
	modulate.a = 0
	await $Timer.timeout
	$Timer.queue_free()
	tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", global_position, 0.2).from(global_position - Vector2(size.x, 0))
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.2).from(Color.TRANSPARENT)
	tween.tween_callback(func (): tween.kill())

func _update_sizes() -> void:
	label.set("theme_override_constants/line_spacing", lineSpacingRef[nbOfLines])
	label.set("theme_override_font_sizes/font_size", fontSizeRef[nbOfLines])

enum MENU_ITEM { EDIT, DELETE }
func _menu_option_seleted(index: int) -> void:
	if index == MENU_ITEM.EDIT:
		pass
	if index == MENU_ITEM.DELETE:
		Backend.delete_message(id)
		queue_free()
