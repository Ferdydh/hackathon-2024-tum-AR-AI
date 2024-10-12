extends CanvasLayer  # Inherit from CanvasLayer since PhoneBook is a CanvasLayer

# Reference to the VBoxContainer where new entries will be added
@onready var container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var button: Button = $Button  # Reference to the button
@onready var http_request: HTTPRequest = $HTTPRequest  # HTTPRequest node reference

# Called when the node is ready
func _ready() -> void:
	# Connect the button's pressed signal to the _on_button_pressed function
	button.pressed.connect(_on_button_pressed)
	# Connect the request_completed signal from HTTPRequest
	http_request.request_completed.connect(self._on_request_completed)

# Function that gets called when the button is pressed
func _on_button_pressed() -> void:
	# Make a GET request to retrieve the friends data
	var err = http_request.request("http://localhost:8000/friends")
	if err != OK:
		print("Error making request: ", err)

# Function to handle the HTTP request's response
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		# Parse the JSON response using the JSON singleton
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var friends = json.data  # The parsed JSON data
			# Clear previous entries in the VBoxContainer to avoid duplicates
			# Loop through each friend and create a new label for their name
			for friend in friends:
				var new_entry = Label.new()
				new_entry.text = friend["name"]
				container.add_child(new_entry)
				# Optionally, print out the friend details (or add them to the UI)
				print(friend["name"] + ": " + str(friend["details"]))
			
			# Scroll to the bottom of the ScrollContainer
			$ScrollContainer.scroll_vertical = $ScrollContainer.get_v_scroll_bar().max_value
			
			# Print to confirm entries have been added
			print("New entries added to the container.")
		else:
			print("Error parsing JSON response.")
	else:
		print("Failed to fetch data. Response code: ", response_code)
