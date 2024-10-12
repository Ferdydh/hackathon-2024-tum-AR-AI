extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ui_panel = Control.new()
	var button = Button.new()
	button.text = "Click me"
	ui_panel.add_child(button)
	add_child(ui_panel)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
