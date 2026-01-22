extends ScrollContainer

@export var list : VBoxContainer

func _ready() -> void:
	list.child_entered_tree.connect(_child_entered_tree)

func _child_entered_tree(node : Node) -> void:
	if get_v_scroll_bar().max_value == (get_v_scroll_bar().value + get_v_scroll_bar().page):
		await RenderingServer.frame_post_draw
		set_deferred("scroll_vertical", get_v_scroll_bar().max_value)
	
