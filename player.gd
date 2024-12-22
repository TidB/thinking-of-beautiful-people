extends CharacterBody3D

var MOUSE_SENSITIVITY = 0.05
const SPEED = 3
const JUMP_VELOCITY = 4.5

var camera
var rotation_helper

var highlighted_obj

func safe_highlighted_obj_check(obj):
	if not is_instance_valid(obj):
		highlighted_obj = null
		return false
	else:
		return true

func _ready():
	camera = $RotationHelper/Camera
	rotation_helper = $RotationHelper

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	check_near_interactable()
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func process_aim(length, mask):
	var size = get_viewport().size
	var from = $RotationHelper/Camera.project_ray_origin(size / 2)
	var to = from + $RotationHelper/Camera.project_ray_normal(size / 2) * length
	
	# TODO: Replace this with the collisionobject3d's input event as mentionedin the docs?
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(from, to, mask)
	return space_state.intersect_ray(params)

func check_near_interactable():
	var result = process_aim(2.0, 0b11)
	
	if result and result["collider"] and result["collider"].collision_layer != 0b1:
		if result["collider"] != highlighted_obj:
			if highlighted_obj:
				highlighted_obj.remove_highlight()
			highlighted_obj = result["collider"]
			highlighted_obj.highlight()
	else:
		if safe_highlighted_obj_check(highlighted_obj):
			highlighted_obj.remove_highlight()
			highlighted_obj = null

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation
		camera_rot.x = deg_to_rad(clamp(rad_to_deg(camera_rot.x), -80, 80))
		rotation_helper.rotation = camera_rot
	elif event.is_action_pressed("interact"):
		if highlighted_obj:
			highlighted_obj.use()
		else:
			pass
			#get_tree().call_group(Global.DIALOGUE_GROUP, "interact")
			
