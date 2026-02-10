extends ScrollContainer

@export var list : VBoxContainer
@export var messageSpawner : Control
@export var messageScene : PackedScene

var messageMemory : Dictionary = {}
var canCreate: bool = true


func _ready() -> void:
	list.child_entered_tree.connect(_child_entered_tree)
	Backend.new_message.connect(_new_message)
	State.channel_changed.connect(_channel_changed)

func _child_entered_tree(node : Node) -> void:
	if get_v_scroll_bar().max_value == (get_v_scroll_bar().value + get_v_scroll_bar().page):
		await RenderingServer.frame_post_draw
		set_deferred("scroll_vertical", get_v_scroll_bar().max_value)

func _add_message_to_memory(message: Dictionary) -> void:
	if messageMemory.get(message["channel_id"]) == null:
		messageMemory.set(message["channel_id"], [])
	messageMemory.get(message["channel_id"]).append(message)

func _new_message(data: Dictionary) -> void:
	_add_message_to_memory(data)
	if data["channel_id"] == State.channelId:
		_create_message(data)

func _create_message(data: Dictionary) -> void:
	var newMessage = messageScene.instantiate()
	newMessage.nbOfLines = 1
	newMessage.id = data["id"]
	newMessage.user = data["user"]
	if data["content"]: newMessage.text = data["content"]
	newMessage.nbOfLines = data["nb_of_lines"]
	if data["has_image"]:
		newMessage.drawing = await Backend.get_message_image(data['id'])
	messageSpawner.add_child(newMessage)

func _clear() -> void:
	var cs : Array = list.get_children()
	for c in cs:
		c.queue_free()

func _load_channel(id: int) -> void:
	if messageMemory.get(id) != null:
		for m in messageMemory.get(id):
			await _create_message(m)
	else:
		var ms : Array = await Backend.get_channel_messages(id)
		ms.reverse()
		for m in ms:
			await _create_message(m)
	await get_tree().create_timer(0.2).timeout
	list.queue_sort()

func _channel_changed(id: int) -> void:
	_clear()
	_load_channel(id)
