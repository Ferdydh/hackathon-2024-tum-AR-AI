extends CanvasLayer

# Reference nodes using @onready keyword
@onready var name_label = $VBoxContainer/NameLabel
@onready var details_container = $VBoxContainer/DetailsContainer
@onready var edit_button = $VBoxContainer/EditButton

# Called when the node enters the scene tree
func _ready():
	# Update the UI initially
	update_ui("Default Name", ["Detail 1", "Detail 2"])
	
	# Connect the button to the edit function
	edit_button.pressed.connect(_on_edit_button_pressed)

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

# Button press function to modify name and details
func _on_edit_button_pressed():
	update_ui("test", ["hi", "test2"])  # Refresh the UI
