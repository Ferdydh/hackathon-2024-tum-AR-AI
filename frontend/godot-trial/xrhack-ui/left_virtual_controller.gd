extends XRController3D

# Function to call when the left trigger is pressed
func _on_trigger_pressed():
	print("Left controller trigger pressed!")
	# Add logic for left-hand interactions here

# Called every frame
func _process(delta):
	# Use `is_action_just_pressed` to detect the trigger press only once
	if Input.is_action_just_pressed("left_trigger"):
		_on_trigger_pressed()
