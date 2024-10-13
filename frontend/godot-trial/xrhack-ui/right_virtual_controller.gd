extends XRController3D

var http_request  # Reference to the dynamically created HTTPRequest node
var canvas_layer  # Reference to the CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create and add the HTTPRequest node dynamically
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	
	# Get reference to the CanvasLayer node by going up and finding the sibling
	canvas_layer = get_node("/root/Main/DetailCanvas")  # Adjust this based on your root node name
	
	# Check if canvas_layer is valid (exists in the scene)
	if canvas_layer:
		# Set CanvasLayer visibility to false initially (if hidden by default)
		#canvas_layer.visible = false
		print("CanvasLayer found and hidden initially.")
	else:
		print("Error: CanvasLayer not found! Verify the node path.")

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

	# Send the POST request to localhost:8000/friends/
	var err = http_request.request_raw(
		"http://127.0.0.1:8000/friends/",  # The URL of your POST endpoint
		headers,                           # Headers for the request
		HTTPClient.METHOD_POST,            # HTTP method
		form_body_bytes                    # Body containing the form data and image
	)

	if err != OK:
		print("Error sending POST request: ", err)

# Handle the response
func _on_request_completed(result, response_code, headers, body):
	print("Request completed with code: ", response_code)

#	Comment out this code to see the screen
	if response_code != 200:
		print("No face")
		return

	# Parse the body as JSON
	var json_result = body.get_string_from_utf8()
	var json_parser = JSON.new()
	var parse_result = json_parser.parse(json_result)

	# Check if the parsing was successful (parse_result returns an int error code)
	if parse_result != OK:
		print("Error parsing JSON. Error code: ", parse_result)
		return

	# If successful, access the parsed data
	var data = json_parser.data  # Get the resulting dictionary
	var id = data.get("id", -1)  # Get the 'name' or default to "Unknown"
	var name = data.get("name", "Unknown")  # Get the 'name' or default to "Unknown"
	var details = data.get("details", [])  # Get the 'details' or default to an empty array
	
	print("Id", id)
	print("Name: ", name)
	print("Details: ", details)
	
	# Check if canvas_layer is valid before setting it to visible
	if canvas_layer:
		canvas_layer.visible = true  # Show the canvas layer when request is completed
		canvas_layer.update_ui(name, details, id)  # Call update_ui() on the canvas layer script (if required)
	else:
		print("Error: CanvasLayer is null or not found! Double-check the node path.")

# Called every frame to detect controller input
func _process(delta):
	# Detect the right trigger press (use is_action_just_pressed to trigger once)
	if Input.is_action_just_pressed("right_trigger"):
		# Call the function to capture and send a screenshot
		send_screenshot()
