extends Node3D


# Everything that follows was literally just copied from the official GUI in 3D demo
# The size of the quad mesh itself.
var quad_mesh_size
# Used for checking if the mouse is inside the Area3D
var is_mouse_inside = false
# Used for checking if the mouse was pressed inside the Area3D
var is_mouse_held = false
# The last non-empty mouse position. Used when dragging outside of the box.
var last_mouse_pos3D = null
# The last processed input touch/mouse event. To calculate relative movement.
var last_mouse_pos2D = null


func _ready() -> void:
	var interactables = get_tree().get_nodes_in_group("interactables")
	for i in interactables:
		i.show_hint.connect($UI._on_show_hint)
		i.hide_hint.connect($UI._on_hide_hint)
		i.switch_camera.connect(self.switch_camera)
	$RoomPlayer/PlayerSITTINGREFERENCE.forward_event.connect(self.forward_event)

	Global.connect("pause", self.pause_unpause)

func pause_unpause(should_pause):
	if not should_pause:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true

func switch_camera():
	#$RoomPlayer/SittingCamera.make_current()
	#$Player.visible = false
	$Player.sit()
	$Player.position = Vector3(1.314, 0.482, 4.465)
	$Player.rotation_degrees = Vector3(0, -90, 0)

func forward_event(event):
	#$RoomPlayer/Desk/SubViewport.push_input(event)
	pass
