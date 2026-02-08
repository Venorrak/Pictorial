extends Node

signal new_message(message: Dictionary)

# TODO: save credentials in local storage
var _jwt : String
var _baseUrl : String = "http://localhost:8080"
var _socket = WebSocketPeer.new()

func _ready() -> void:
	set_process(false)
	var auth = _loadAuth()
	if auth:
		await login(auth["name"], auth["password"])

func login(username: String, password: String) -> bool: ## POST /api/v1/auth/login
	var body : String = JSON.stringify({
		"name": username,
		"password": password
	})
	var resp : HTTPResult = await async_request.async_request_strap(
		self, _baseUrl + "/api/v1/auth/login", [], HTTPClient.METHOD_POST, body)
	if resp.success():
		if resp.status_ok():
			var r : Dictionary = resp.body_as_variant() as Dictionary
			_jwt = r["token"]
			_saveAuth(username, password)
			connect_websocket()
			return true
		else:
			Log.error(_baseUrl + "/api/v1/auth/login : " + resp.body_as_variant()["error"])
	return false

func logout() -> void:
	_jwt = ""
	disconnect_websocket()
	_clearAuth()

func register(username: String, password: String) -> bool: ## POST /api/v1/auth/register
	var body : String = JSON.stringify({
		"name": username,
		"password": password
	})
	var resp : HTTPResult = await async_request.async_request_strap(
		self, _baseUrl + "/api/v1/auth/register", [], HTTPClient.METHOD_POST, body)
	if resp.success():
		if resp.status_ok():
			var r : Dictionary = resp.body_as_variant() as Dictionary
			_jwt = r["token"]
			_saveAuth(username, password)
			return true
		else:
			Log.error(_baseUrl + "/api/v1/auth/register : " + resp.body_as_variant()["error"])
	return false

func create_channel(channelName: String, description: String) -> bool: ## POST /api/v1/channels
	var body : String = JSON.stringify({
		"name": channelName,
		"description": description
	})
	var resp : HTTPResult = await async_request.async_request_strap(
		self, _baseUrl + "/api/v1/channels", ["Authorization: Bearer " + _jwt], HTTPClient.METHOD_POST, body)
	if resp.success():
		if resp.status_ok():
			var r : Dictionary = resp.body_as_variant() as Dictionary
			Log.pr(r)
			return true
		else:
			Log.error(_baseUrl + "/api/v1/channels : " + resp.body_as_variant()["error"])
	return false

func get_channels() -> Array[Dictionary]: ## GET /api/v1/channels
	var resp : HTTPResult = await async_request.async_request_strap(
		self, _baseUrl + "/api/v1/channels", ["Authorization: Bearer " + _jwt])
	if resp.success():
		if resp.status_ok():
			var r : Array[Dictionary] = resp.body_as_variant() as Array[Dictionary]
			Log.pr(r)
			return r
		else:
			Log.error(_baseUrl + "/api/v1/channels : " + resp.body_as_variant()["error"])
	return []
	
func get_channel(id: int) -> Dictionary: ## GET /api/v1/channels/:id
	var resp : HTTPResult = await  async_request.async_request_strap(
		self, _baseUrl + "/api/v1/channels/" + str(id), ["Authorization: Bearer " + _jwt])
	if resp.success():
		if resp.status_ok():
			var r : Dictionary = resp.body_as_variant() as Dictionary
			Log.pr(r)
			return r
		else:
			Log.error(_baseUrl + "/api/v1/channels/" + str(id) + " : " + resp.body_as_variant()["error"])
	return {}

func update_channel(id: int, channelName: String, description: String) -> bool: ## PUT /api/v1/channels/:id
	var body : String = JSON.stringify({
		"name": channelName,
		"description": description
	})
	var resp : HTTPResult = await async_request.async_request_strap(
		self, _baseUrl + "/api/v1/channels/" + str(id), ["Authorization: Bearer " + _jwt], HTTPClient.METHOD_PUT, body)
	if resp.success():
		if resp.status_ok():
			var r : Dictionary = resp.body_as_variant() as Dictionary
			Log.pr(r)
			return true
		else:
			Log.error(_baseUrl + "/api/v1/channels/" + str(id) + " : " + resp.body_as_variant()["error"])
	return false

func delete_channel(id: int) -> bool: ## DELETE /api/v1/channels/:id
	var resp: HTTPResult = await async_request.async_request_strap(
		self, _baseUrl + "/api/v1/channels/" + str(id), ["Authorization: Bearer " + _jwt], HTTPClient.METHOD_DELETE)
	if resp.success():
		if resp.status_ok():
			var r : Dictionary = resp.body_as_variant() as Dictionary
			Log.pr(r)
			return true
		else:
			Log.error(_baseUrl + "/api/v1/channels/" + str(id) + " : " + resp.body_as_variant()["error"])
	return false

func get_channel_messages(channelId: int, page: int = 1, limit: int = 20) -> Array[Dictionary]: ## GET /api/v1/channels/:id/messages?page=1&limit=50
	var resp: HTTPResult = await async_request.async_request_strap(
		self, _baseUrl + "/api/v1/channels/" + str(channelId) + "/messages?page=" + str(page) + "&limit=" + str(limit), ["Authorization: Bearer " + _jwt])
	if resp.success():
		if resp.status_ok():
			var r : Array[Dictionary] = resp.body_as_variant() as Array[Dictionary]
			Log.pr(r)
			return r
		else:
			Log.error(_baseUrl + "/api/v1/channels/" + str(channelId) + "/messages : " + resp.body_as_variant()["error"])
	return []
	
func create_message(channelId: int, text, image) -> bool: ## POST /api/v1/messages
	var b : Dictionary = {
		"channel_id": channelId
	}
	if text: b.set("content", text)
	if image:
		image = image as Image
		var image64 : String = Marshalls.raw_to_base64(image.save_png_to_buffer())
		b.set("image_data", image64)
	var body : String = JSON.stringify(b)
	var resp: HTTPResult = await async_request.async_request_strap(
		self, _baseUrl + "/api/v1/messages", ["Authorization: Bearer " + _jwt], HTTPClient.METHOD_POST, body)
	if resp.success():
		if resp.status_ok():
			var r : Dictionary = resp.body_as_variant() as Dictionary
			Log.pr(r)
			return true
		else:
			Log.error(_baseUrl + "/api/v1/messages : " + resp.body_as_variant()["error"])
	return false
	
func get_message(id: int) -> Dictionary: ## GET /api/v1/messages/:id
	var resp : HTTPResult = await async_request.async_request_strap(
		self, _baseUrl + "/api/v1/messages/" + str(id), ["Authorization: Bearer " + _jwt])
	if resp.success():
		if resp.status_ok():
			var r : Dictionary = resp.body_as_variant() as Dictionary
			Log.pr(r)
			return r
		else:
			Log.error(_baseUrl + "/api/v1/messages:" + str(id) + " : " + resp.body_as_variant()["error"])
	return {}
	
func get_message_image(id: int) -> Image: ## GET /api/v1/messages/:id/image
	var resp : HTTPResult = await async_request.async_request_strap(
		self, _baseUrl + "/api/v1/messages/" + str(id) + "/image", ["Authorization: Bearer " + _jwt])
	if resp.success():
		if resp.status_ok():
			var r : PackedByteArray = resp.bytes
			var img : Image = Image.new()
			var err : Error = img.load_png_from_buffer(r)
			if err == 0: return img
			Log.err("could not load png from buffer")
		else:
			Log.error(_baseUrl + "/api/v1/messages:" + str(id) + "/image : " + resp.body_as_variant()["error"])
	return Image.create_empty(468, 170, false, Image.FORMAT_RGBA8)
	
func delete_message(id: int) -> bool: ## DELETE /api/v1/messages/:id
	var resp : HTTPResult = await async_request.async_request_strap(
		self, _baseUrl + "/api/v1/messages:" + str(id), ["Authorization: Bearer " + _jwt], HTTPClient.METHOD_DELETE)
	if resp.success():
		if resp.status_ok():
			var r : Dictionary = resp.body_as_variant() as Dictionary
			Log.pr(r)
			return true
		else:
			Log.error(_baseUrl + "/api/v1/messages:" + str(id) + " : " + resp.body_as_variant()["error"])
	return false

# WEBSOCKET

func connect_websocket() -> void:
	_socket.connect_to_url("ws" + _baseUrl.trim_prefix("http").trim_prefix("https") + "/api/v1/ws?token=" + _jwt)
	set_process(true)

func disconnect_websocket() -> void:
	_socket.close()

func subscribe_channel(id: int) -> void:
	if _socket.get_ready_state() == WebSocketPeer.STATE_CLOSED: return
	_socket.send_text(JSON.stringify({
		"type": "subscribe",
		"channel_id": id
	}))

func unsubscibe_channel(id: int) -> void:
	if _socket.get_ready_state() == WebSocketPeer.STATE_CLOSED: return
	_socket.send_text(JSON.stringify({
		"type": "unsubscribe",
		"channel_id": id
	}))

func _process(delta: float) -> void:
	_socket.poll()
	var state = _socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while _socket.get_available_packet_count():
			var packet : Dictionary = JSON.parse_string(_socket.get_packet().get_string_from_utf8())
			Log.pr(packet)
			new_message.emit(packet)
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = _socket.get_close_code()
		var reason = _socket.get_close_reason()
		Log.warn("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

## AUTH

const saveLocation: String = "user://dontlookhere.json"
func _saveAuth(username: String, password: String):
	# TODO: different method for the web (look at JAVASCRIPTOBJECT)
	var file = FileAccess.open(saveLocation, FileAccess.WRITE)
	file.store_var({
		"name": username,
		"password": password
	})
	file.close()

func _loadAuth() -> Dictionary:
	# TODO: different method for the web
	if FileAccess.file_exists(saveLocation):
		var file = FileAccess.open(saveLocation, FileAccess.READ)
		var data = file.get_var()
		file.close()
		if data == null: return {}
		return data as Dictionary
	return {}

func _clearAuth() -> void:
	var file = FileAccess.open(saveLocation, FileAccess.WRITE)
	file.store_var(null)
	file.close()
	
