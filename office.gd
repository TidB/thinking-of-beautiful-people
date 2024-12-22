extends Node3D


func _ready() -> void:
	var interactables = get_tree().get_nodes_in_group("interactables")
	print(interactables)
	for i in interactables:
		i.show_hint.connect($UI._on_show_hint)
		i.hide_hint.connect($UI._on_hide_hint)
		i.switch_camera.connect(self.switch_camera)

	Global.connect("pause", self.pause_unpause)

func pause_unpause(should_pause):
	if not should_pause:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true

func switch_camera():
	$RoomPlayer/SittingCamera.make_current()
	$Player.visible = false
