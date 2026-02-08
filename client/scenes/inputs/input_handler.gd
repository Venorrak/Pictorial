extends PanelContainer
class_name inputHandler

@export var textInput : TextInput
@export var canvasInput : CanvasInput

var fontSizeRef : PackedInt32Array = [35, 39, 43, 47, 51]
var lineSpacingRef : PackedInt32Array = [6, 7, 8, 9, 9]

func send() -> void:
	var height : int = max(textInput.get_number_of_lines_used(), canvasInput.get_number_of_lines_used())
	if not height: return
	var img = canvasInput.get_lines(height)
	var text = textInput.text
	
	if textInput.get_number_of_lines_used() == 0:
		text = null
	if canvasInput.get_number_of_lines_used() == 0:
		img = null

	Backend.create_message(1, text, img)
	
	textInput.clear()
	canvasInput._reset()

var zoomLevel : int = 0
func _zoom() -> void:
	if zoomLevel >= 4: return
	custom_minimum_size.y += 20
	zoomLevel += 1
	_update_sizes()
func _unzoom() -> void:
	if zoomLevel <= 0: return
	custom_minimum_size.y -= 20
	zoomLevel -= 1
	_update_sizes()

func _update_sizes() -> void:
	textInput.set("theme_override_constants/line_spacing", lineSpacingRef[zoomLevel])
	textInput.set("theme_override_font_sizes/font_size", fontSizeRef[zoomLevel])
	

# 4 - 185l - 6h - 35s -> 51s 9h
# 3 - 170l - 6h - 35s -> 47s 9h
# 2 - 155l - 6h - 35s -> 43s 8h
# 1 - 140l - 6h - 35s -> 39s 7h
# 0 - 125l - 6h - 35s -> 35s 6h
