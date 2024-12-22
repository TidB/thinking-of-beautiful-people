extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_show_hint(text):
	$HUD/CenterContainer/Hint.text = text
	$HUD/CenterContainer/Crosshair.visible = false

func _on_hide_hint():
	$HUD/CenterContainer/Hint.text = ""
	$HUD/CenterContainer/Crosshair.visible = true
