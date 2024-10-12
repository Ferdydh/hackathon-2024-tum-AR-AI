extends CanvasLayer

# Reference nodes using @onready keyword
@onready var name_label = $VBoxContainer/NameLabel
@onready var details_container = $VBoxContainer/DetailsContainer
@onready var edit_button = $VBoxContainer/EditButton
@onready var name_input = $VBoxContainer/NameInput
@onready var details_input = $VBoxContainer/DetailsInput

# Variable to track if we are in edit mode
var is_editing = false

# Called when the node enters the scene tree
func _ready():
	# Initialize UI with default values
	update_ui("Default Name", ["Detail 1", "Detail 2"])
	
	# Connect the edit button to toggle between Edit and Save
	edit_button.pressed.connect(_on_edit_button_pressed)

	# Hide the LineEdit fields initially
	name_input.visible = false
	details_input.visible = false

# Function to update the UI dynamically
func update_ui(friend_name: String, friend_detail_list: Array):
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

# Function to save data (implementation to be added later)
func save_data():
	# Get the text from the LineEdit fields
	var new_name = name_input.text
	var new_details = details_input.text.split(",")
	
	# Refresh the UI with the new values
	update_ui(new_name, new_details)
	
	# You can later implement additional functionality for saving the data, e.g., storing it persistently
