extends HTTPRequest
class_name async_request

signal request_finished

func async_request(url: String, custom_headers:= PackedStringArray(), method: HTTPClient.Method= HTTPClient.METHOD_GET, request_data := "") -> HTTPResult:
	var err := request(url, custom_headers, method, request_data)
	if err:
		return HTTPResult._from_error(err)
	var result : Array = await request_completed as Array
	request_finished.emit()
	
	return HTTPResult._from_array(result)

static func async_request_strap(parent: Node, url: String, custom_headers:= PackedStringArray(), method: HTTPClient.Method = HTTPClient.METHOD_GET, request_data := "") -> HTTPResult:
	var _request : async_request = async_request.new()
	parent.add_child(_request)
	var res : HTTPResult = await _request.async_request(url, custom_headers, method, request_data)
	_request.queue_free()
	return res
