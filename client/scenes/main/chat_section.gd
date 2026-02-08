extends ScrollContainer

@export var list : VBoxContainer
@export var messageSpawner : Control
@export var messageScene : PackedScene

func _ready() -> void:
	list.child_entered_tree.connect(_child_entered_tree)
	Backend.new_message.connect(_new_message)

func _child_entered_tree(node : Node) -> void:
	if get_v_scroll_bar().max_value == (get_v_scroll_bar().value + get_v_scroll_bar().page):
		await RenderingServer.frame_post_draw
		set_deferred("scroll_vertical", get_v_scroll_bar().max_value)
	
func _new_message(data: Dictionary) -> void:
	var newMessage = messageScene.instantiate()
	newMessage.nbOfLines = 4
	newMessage.text = data["content"]
	#newMessage.drawing = img
	messageSpawner.add_child(newMessage)
