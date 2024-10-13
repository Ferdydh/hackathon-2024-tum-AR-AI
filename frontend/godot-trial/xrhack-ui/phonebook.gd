extends CanvasLayer  # Inherit from CanvasLayer since PhoneBook is a CanvasLayer

# Reference to the VBoxContainer where new entries will be added
@onready var container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var http_request: HTTPRequest = $HTTPRequest  # HTTPRequest node reference
@onready var canvas_layer = get_node("/root/Main/DetailCanvas")  # Reference to the other CanvasLayer
@onready var timer: Timer = get_node("/root/Main/Timer")
@onready var scroll_container: ScrollContainer = $ScrollContainer

# Called when the node is ready
func _ready() -> void:
	# Connect the request_completed signal from HTTPRequest
	http_request.request_completed.connect(self._on_request_completed)
	# Automatically make the GET request when the scene is ready
	load_friends()
	timer.autostart = true

# Function to load friends from the API
func load_friends() -> void:
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
			# Loop through each friend and create a new button for their name
			for friend in friends:
				var new_entry = Button.new()
				new_entry.text = friend["name"]
				# Connect the button's pressed signal to a function to handle clicks and pass friend data
				new_entry.pressed.connect(self._on_friend_button_pressed.bind(friend))
				container.add_child(new_entry)
				print(friend["name"] + ": " + str(friend["details"]))
						
			# Print to confirm entries have been added
			print("New entries added to the container.")
		else:
			print("Error parsing JSON response.")
	else:
		print("Failed to fetch data. Response code: ", response_code)


func _on_friend_button_pressed(friend_data: Dictionary) -> void:
	# Call the update_ui method of the CanvasLayer to update the display
	canvas_layer.update_ui(friend_data["name"], friend_data["details"])
	print("You clicked on: " + friend_data["name"])
	print("Details: " + str(friend_data["details"]))
	
# TODO: update doesn't work, jadi duplicate because of ID increment.
func _on_timer_timeout() -> void:
	for child in container.get_children():
		child.queue_free()
	print('load friends')
	load_friends()
