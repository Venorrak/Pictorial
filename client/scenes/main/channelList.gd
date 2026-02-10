extends VBoxContainer

var channels : Array[channelLabel] = []
@export var channelScene : PackedScene

func _ready() -> void:
	Backend.logged_in.connect(_on_logged_in)
	
func _on_logged_in() -> void:
	var list : Array = await Backend.get_channels()
	for c in list:
		var newChannel : channelLabel = channelScene.instantiate()
		newChannel.text = "# " + c["name"]
		newChannel.id = c["id"]
		channels.append(newChannel)
		newChannel._select.connect(_newSelected)
		add_child(newChannel)
	if channels.size():
		channels[0].selected = true

func _newSelected(channel: channelLabel) -> void:
	State.channelId = channel.id
	for c in channels:
		if c.selected == true && not channel == c:
			c.selected = false
			Backend.unsubscibe_channel(c.id)
	Backend.subscribe_channel(channel.id)
