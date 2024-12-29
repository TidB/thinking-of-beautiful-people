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
	$RoomPlayer/Chair/SitDown.switch_camera.connect(self.switch_camera)
	$RoomPlayer/Node/HopOver.switch_final_camera.connect(self.switch_final_camera)

	Global.connect("pause", self.pause_unpause)
	$RoomPlayer/Chair/SitDown.close_door.connect(func(): $RoomPlayer/Node/AnimationPlayer.play("close"))
	$RoomPlayer/Desk/GuiPanel3d/SubViewport/Idle.start_main_dialogue.connect(self.start_main)
	$RoomPlayer/Bubbles.happening.connect(self.happening)
	#switch_camera()
	#switch_final_camera()
	$RoomPlayer/Desk/GuiPanel3d/SubViewport/Idle.backup_mode(true)
	$Sun/AnimationPlayer.play("wander", -1, 0.0001, true)
	$RoomPlayer/Node/AnimationPlayer.play("break")
	

func pause_unpause(should_pause):
	if not should_pause:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true

func switch_camera():
	$RoomPlayer/Bubbles/IntroBubbles.visible = false
	$Player.sit()
	$Player.position = Vector3(1.314, 0.482, 4.465)
	$Player.rotation_degrees = Vector3(0, -90, 0)
	
func switch_final_camera():
	$Player.stand()
	$Player.position = Vector3(4.352, 0.875, 0.097)
	$Player.rotation = Vector3(0, 0, 0)

func start_main():
	$RoomPlayer/Node/cabinet_pivot.visible = true
	$RoomPlayer/Node/AnimationPlayer.play("break")
	$RoomPlayer/Bubbles/NormalBubbles.visible = true
	$RoomPlayer/Bubbles.start()
	
func happening(code):
	print("happening:", code)
	if code == 'GARBAGE':
		$"light-fx/garbage".visible = true
		$"light-fx/garbage/AnimationPlayer".play("garbage")
		$"light-fx/garbage/AnimationPlayer2".play("move_garbage")
		
		$Sun/AnimationPlayer.animation_finished.connect(func(name): $Sun.visible = false)
		$Sun/AnimationPlayer.play("wander")
	elif code == 'EMERGENCY':
		$"light-fx/garbage".visible = false
		$"light-fx/emergency".visible = true
		$"light-fx/emergency/AnimationPlayer".play("strobe")
		$"light-fx/emergency/AnimationPlayer2".play("move_emergency")
		Audio.play_siren()
	elif code == 'STOPSIREN':
		Audio.stop_siren()
	elif code == 'STREETLAMPS':
		$"light-fx/emergency".visible = false
		$"light-fx/streetlamp".visible = true
	elif code == 'CAR':
		$Sun.visible = false
		
		$"light-fx/streetlamp".visible = false
		$"light-fx/car/Path3D/PathFollow3D/car".visible = true
		$"light-fx/car/Path3D/PathFollow3D/AnimationPlayer".play("i_drive")
	elif code == 'BLACKOUT':
		$"light-fx/car/Path3D/PathFollow3D/car".visible = false
		$"light-fx/light".visible = false
		$"light-fx/streetlamp".visible = false
	elif code == 'BACKUP':
		$"light-fx/backup".visible = true
		$RoomPlayer/Desk/GuiPanel3d/SubViewport/Idle.backup_mode(true)
	elif code == 'EXPLOSION':
		$"light-fx/explosion".visible = true
		$"light-fx/explosion/AnimationPlayer".play("bang")
		Audio.play_explosion()
	elif code == 'FIREWORKS':
		$"light-fx/explosion".visible = false
		$"light-fx/fireworks".visible = true
		$"light-fx/fireworks".start()
	elif code == 'BLIND':
		$"light-fx/fireworks".stop()
		$"light-fx/fireworks".visible = false
		$"light-fx/streetlamp".visible = false
	elif code == 'FIRE':
		$"light-fx/fire".visible = true
		$"light-fx/fire/AnimationPlayer".animation_finished.connect(func(name): $"light-fx/fire/AnimationPlayer".play("fire"))
		$"light-fx/fire/AnimationPlayer".play("start_fire")
	elif code == 'SMOKE':
		$WorldEnvironment.environment.volumetric_fog_enabled = true
		$WorldEnvironment/AnimationPlayer.play("smoke")
	elif code == 'FLASHLIGHT':
		$"light-fx/fire/AnimationPlayer".stop()
		$"light-fx/fire".visible = false
		$"light-fx/flashlights".visible = true
		$"light-fx/flashlights/AnimationPlayer".play("search")
		for bubble in [$RoomPlayer/Bubbles/NormalBubbles/Sarah, $RoomPlayer/Bubbles/NormalBubbles/Alex, $RoomPlayer/Bubbles/NormalBubbles/Mitchell]:
			bubble.font_size = 35
	elif code == 'NIGHT':
		$"light-fx/flashlights/AnimationPlayer".stop()
		$"light-fx/flashlights".visible = false
		$Sun.visible = true
		$Sun/AnimationPlayer.play("rise")
		$WorldEnvironment.environment.volumetric_fog_density = 0.07
		$RoomPlayer/Bubbles/NormalBubbles/Alex.font_size = 52
		$RoomPlayer/Node/cabinet_pivot/Cabinet2/StaticBody3D/CollisionShape3D.disabled = false
	elif code == 'END':
		$"light-fx/backup".visible = false
		$RoomPlayer/Desk/GuiPanel3d/SubViewport/Idle.backup_mode(false)
		$RoomPlayer/Node/HopOver/CollisionShape3D.disabled = false
		$Player.allow_interaction()
	else:
		print('unknown code', code)
