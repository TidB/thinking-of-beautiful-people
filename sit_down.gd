extends StaticBody3D

signal interacted(state)
signal show_hint(text)
signal hide_hint
signal switch_camera
signal close_door

var used = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('cool')
	add_to_group("interactables")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func highlight():
	show_hint.emit('SIT DOWN')
	
func remove_highlight():
	hide_hint.emit()
	
func use():
	if used:
		return
		
	remove_highlight()
	switch_camera.emit()
	close_door.emit()
	self.visible = false
	used = true

func _on_show_hint(text):
	$HUD/CenterContainer/Hint.text = text
	$HUD/CenterContainer/Crosshair.visible = false

func _on_hide_hint():
	$HUD/CenterContainer/Hint.text = ""
	$HUD/CenterContainer/Crosshair.visible = true
