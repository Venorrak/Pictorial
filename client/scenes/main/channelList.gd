extends VBoxContainer

var channels : Array[channelLabel] = []

func _ready() -> void:
	for c in get_children():
		if c is channelLabel:
			channels.append(c)
			c._select.connect(_newSelected)

func _newSelected(channel: Label) -> void:
	for c in channels:
		if c.selected == true && not channel == c:
			c.selected = false
