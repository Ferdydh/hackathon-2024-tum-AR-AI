extends XRController3D

var http_request  # Reference to the dynamically created HTTPRequest node

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create and add the HTTPRequest node dynamically
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))

# Function to capture the current viewport and send the image in a POST request
func send_screenshot():
	# Get the current viewport texture
	var viewport_texture = get_viewport().get_texture()
	
	# Get the image from the viewport texture
	var viewport_image = viewport_texture.get_image()

	if viewport_image == null:
		print("Failed to capture the viewport image")
		return

	# Convert the image to PNG format and get it as raw binary data
	var image_data = viewport_image.save_png_to_buffer()

	# Generate a unique boundary
	var crypto = Crypto.new()
	var random_bytes = crypto.generate_random_bytes(16)
	var boundary = "GODOT%s" % random_bytes.hex_encode()
	
	# Formulate the multipart data for the image
	var form_body = "--" + boundary + "\r\n"
	form_body += 'Content-Disposition: form-data; name="file"; filename="screenshot.png"\r\n'
	form_body += "Content-Type: image/png\r\n\r\n"
	
	# Convert form_body to bytes
	var form_body_bytes = form_body.to_utf8()
	
	# Append the image data
	form_body_bytes.append_array(image_data)  # Append raw binary image data
	
	# Append closing boundary
	var closing_boundary = "\r\n--" + boundary + "--\r\n"
	form_body_bytes.append_array(closing_boundary.to_utf8())

	# Set up the headers
	var headers = [
		"Content-Type: multipart/form-data; boundary=" + boundary
	]

	# Send the POST request using request_raw
	var err = http_request.request_raw(
		"http://localhost:8000/friends",
		headers,
		HTTPClient.METHOD_POST,
		form_body_bytes
	)

	if err != OK:
		print("Error sending POST request: ", err)

# Handle the response
func _on_request_completed(result, response_code, headers, body):
	print("Request completed with code: ", response_code)
	print("Response: ", body.get_string_from_utf8())

# Called every frame to detect controller input
func _process(delta):
	# Detect the right trigger press (use is_action_just_pressed to trigger once)
	if Input.is_action_just_pressed("right_trigger"):
		# Call the function to capture and send a screenshot
		send_screenshot()
