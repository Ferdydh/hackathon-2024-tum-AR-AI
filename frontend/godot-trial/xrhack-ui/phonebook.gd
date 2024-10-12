extends CanvasLayer  # Inherit from CanvasLayer since PhoneBook is a CanvasLayer

# Reference to the VBoxContainer where new entries will be added
@onready var container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var button: Button = $Button  # Reference to the button

# Called when the node is ready
func _ready() -> void:
	# Connect the button's pressed signal to the _on_button_pressed function
	button.pressed.connect(_on_button_pressed)

# Function that gets called when the button is pressed
func _on_button_pressed() -> void:
	# Print to output when the button is pressed
	print("Button was pressed!")

	# Create a new label (or any other UI element you want to add)
	var new_entry = Label.new()
	
	# Set the text of the new label
	new_entry.text = "New Entry " + str(container.get_child_count() + 1)
	
	# Add the new entry to the VBoxContainer
	container.add_child(new_entry)

	# Scroll to the bottom of the ScrollContainer
	$ScrollContainer.scroll_vertical = $ScrollContainer.get_v_scroll_bar().max_value

	# Print to output to confirm that a new entry has been added
	print("New entry added to the container.")
