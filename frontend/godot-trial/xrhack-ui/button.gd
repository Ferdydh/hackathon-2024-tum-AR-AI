extends Button

# Placeholder URL for the API
var api_url: String = "https://your-api.com/process-image"

func _ready():
	# Correct connection method for Godot 4.x
	connect("pressed", Callable(self, "_on_button_pressed"))

# Function to capture VR passthrough and send it to the API
func _on_button_pressed():
	var image = self.get_parent().capture_vr_passthrough()
	
	if image != null:
		self.get_parent().send_image_to_api(image)

# Capture image from VR passthrough (simplified example)
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
	var err = self.get_parent().http_request.request_raw(
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
