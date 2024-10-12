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

	# Convert the image to JPEG format and get it as raw binary data
	var image_data = viewport_image.save_jpg_to_buffer()  # Saving as JPG since your cURL example uses JPEG

	# Set up the multipart form-data, including binary data as part of an array `image`
	var boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"  # Standard boundary for multipart requests
	
	# Formulate the multipart data, including binary data
	var form_body = "--" + boundary + "\r\n"
	form_body += 'Content-Disposition: form-data; name="image"; filename="screenshot.jpg"\r\n'
	form_body += "Content-Type: image/jpeg\r\n\r\n"
	
	var form_body_bytes = form_body.to_utf8_buffer()
	form_body_bytes.append_array(image_data)  # Append raw binary image data
	form_body_bytes.append_array(("\r\n--" + boundary + "--\r\n").to_utf8_buffer())

	# Set up the headers (multipart/form-data)
	var headers = [
		"accept: application/json",  # Add this to match your cURL command
		"Content-Type: multipart/form-data; boundary=" + boundary
	]

	# Send the POST request to localhost:8000/friends/search_by_image (as per the updated cURL)
	var err = http_request.request_raw(
		"http://127.0.0.1:8000/friends/search_by_image",  # Updated URL for the POST endpoint
		headers,                           # Headers for the request
		HTTPClient.METHOD_POST,            # HTTP method
		form_body_bytes                    # Body containing the form data and image
	)

	if err != OK:
		print("Error sending POST request: ", err)

# Handle the response
func _on_request_completed(result, response_code, headers, body):
	print("Request completed with code: ", response_code)
	print("Response: ", body.get_string_from_utf8())  # Convert body to string for readability

# Called every frame to detect controller input
func _process(delta):
	# Detect the left trigger press (use is_action_just_pressed to trigger once)
	if Input.is_action_just_pressed("left_trigger"):
		# Call the function to capture and send a screenshot
		send_screenshot()
