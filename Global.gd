extends Node

signal pause(should_pause)
var is_paused = false

var TEXT_SPEED = 0.7


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		is_paused = not is_paused
		pause.emit(is_paused)
