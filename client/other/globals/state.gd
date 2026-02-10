extends Node

signal channel_changed(id: int)
var channelId : int:
	set(value):
		channelId = value
		channel_changed.emit(channelId)
