extends PanelContainer

var nbOfLines : int
var text : String
var drawing : Image
var tween : Tween

@export var sprites : Array[Texture2D]
@export var bg : TextureRect
@export var canvas : TextureRect
@export var label : Label

var fontSizeRef : PackedInt32Array = [35, 39, 43, 47, 51]
var lineSpacingRef : PackedInt32Array = [6, 7, 8, 9, 9]
var targetPosition: Vector2

func _ready() -> void:
	bg.texture = sprites[nbOfLines - 1]
	canvas.texture = ImageTexture.create_from_image(drawing)
	label.text = text
	modulate.a = 0
	#await RenderingServer.frame_post_draw #fuck this
	await $Timer.timeout
	$Timer.queue_free()
	tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", global_position, 0.2).from(global_position - Vector2(size.x, 0))
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.2).from(Color.TRANSPARENT)
	tween.tween_callback(func (): tween.kill())

func _update_sizes() -> void:
	label.set("theme_override_constants/line_spacing", lineSpacingRef[nbOfLines])
	label.set("theme_override_font_sizes/font_size", fontSizeRef[nbOfLines])
