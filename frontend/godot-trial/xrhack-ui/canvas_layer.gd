extends CanvasLayer

# Reference nodes using @onready keyword
@onready var name_label = $VBoxContainer/NameLabel
@onready var details_container = $VBoxContainer/DetailsContainer
@onready var edit_button = $VBoxContainer/EditButton
@onready var name_input = $VBoxContainer/NameInput
@onready var details_input = $VBoxContainer/DetailsInput

# Variable to track if we are in edit mode
var is_editing = false
var http_request  # HTTPRequest node for PUT request
var friend_id

# Called when the node enters the scene tree
func _ready():
	# Initialize UI with default values
	update_ui("Default Name", ["Detail 1", "Detail 2"])
	
#	Mocked for now
	friend_id = 1
	
	# Connect the edit button to toggle between Edit and Save
	edit_button.pressed.connect(_on_edit_button_pressed)

	# Hide the LineEdit fields initially
	name_input.visible = false
	details_input.visible = false

	# Create and add the HTTPRequest node dynamically
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))

# Function to update the UI dynamically
func update_ui(friend_name: String, friend_detail_list: Array, optional_param: int = -1):
	if optional_param != -1:
		friend_id = optional_param
	
	# Update the name label
	name_label.text = "Name: %s" % friend_name
	
	# Clear existing detail labels
	for child in details_container.get_children():
		child.queue_free()
	
	# Add labels dynamically for each detail
	for detail in friend_detail_list:
		var detail_label = Label.new()
		detail_label.text = "- %s" % detail
		details_container.add_child(detail_label)

# Button press function to toggle between Edit and Save
func _on_edit_button_pressed():
	if is_editing:
		# If we are editing, save the data
		save_data()
		# Hide LineEdit fields
		name_input.visible = false
		details_input.visible = false
		# Show the labels back
		name_label.visible = true
		for child in details_container.get_children():
			child.visible = true
		# Change button text to "Edit"
		edit_button.text = "Edit"
	else:
		# If not editing, switch to edit mode
		start_editing()
		# Show LineEdit fields
		name_input.visible = true
		details_input.visible = true
		# Hide the labels while editing
		name_label.visible = false
		for child in details_container.get_children():
			child.visible = false
		# Change button text to "Save"
		edit_button.text = "Save"
	is_editing = !is_editing

# Function to start editing (populates the LineEdit fields with current data)
func start_editing():
	# Extract current name from name label (removing the "Name: " prefix)
	var current_name = name_label.text.replace("Name: ", "")
	# Extract current details from details container
	var current_details = []
	for child in details_container.get_children():
		current_details.append(child.text.replace("- ", ""))
	
	# Pre-fill LineEdit fields with the current values
	name_input.text = current_name
	
	# Manually join the array into a comma-separated string
	var details_text = ""
	for i in range(current_details.size()):
		details_text += current_details[i]
		if i < current_details.size() - 1:
			details_text += ", "  # Add comma and space between elements
	
	details_input.text = details_text

# Function to save data (now sends a PUT request)
func save_data():
	# Get the text from the LineEdit fields
	var new_name = name_input.text
	# Split the details by commas and trim any whitespace from each item using `strip_edges`
	var new_details = []
	for detail in details_input.text.split(","):
		new_details.append(detail.strip_edges())  # Trim spaces from both ends

	# Refresh the UI with the new values
	update_ui(new_name, new_details)

	# Prepare the data for PUT request
	var json_data = {
		"name": new_name,
		"details": new_details
	}
	var json_string = JSON.stringify(json_data)

	# Set up the headers for the PUT request
	var headers = [
		"accept: application/json",
		"Content-Type: application/json"
	]

	var url = "http://127.0.0.1:8000/friends/%s" % str(friend_id)  # Using string interpolation


	var err = http_request.request(
		url,                     # The URL to send the request to
		headers,                 # The request headers
		HTTPClient.METHOD_PUT,   # HTTP PUT method
		json_string              # The request body (JSON data)
	)

	if err != OK:
		print("Error sending PUT request: ", err)

# Handle the response from the HTTP PUT request
func _on_request_completed(result, response_code, headers, body):
	print("Request completed with code: ", response_code)

	if response_code != 200:
		print("Failed to save data")
		return

	# Optionally handle response data here
	var json_result = body.get_string_from_utf8()
	var json_parser = JSON.new()
	var parse_result = json_parser.parse(json_result)

	if parse_result != OK:
		print("Error parsing JSON. Error code: ", parse_result)
		return

	var data = json_parser.data  # Get the resulting dictionary
	print("Server response: ", data)
