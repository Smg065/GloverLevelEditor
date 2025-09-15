extends Node3D
class_name CameraControls

@export var camera : Camera3D
@export var speed : float

func _process(delta: float) -> void:
	var moveInput : Vector2 = Vector2(Input.get_axis("MoveLeft","MoveRight"), Input.get_axis("MoveForward","MoveBack")).normalized() * speed
	var cameraInput : Vector2 = Vector2(Input.get_axis("CameraRight","CameraLeft"), Input.get_axis("CameraDown","CameraUp")).normalized()
	var moveDirection : Vector3 = Vector3(moveInput.x, 0, moveInput.y)
	
	global_position += global_basis * moveDirection * delta * 4
	if cameraInput.length_squared() > 0:
		rotate_camera_x(cameraInput.x, delta)
		rotate_camera_y(cameraInput.y, delta)

func rotate_camera_y(yInput : float, delta : float):
	var originalX : float = camera.global_rotation.x
	camera.global_rotation.x += yInput * delta * 2
	if global_rotation.x < -1.3 or global_rotation.x > 1.3:
		camera.global_rotation.x = originalX
		return
	global_position = camera.global_position + (camera.global_basis * Vector3.FORWARD * global_position.distance_to(camera.global_position))
	camera.global_rotation.x = originalX
	global_rotation.x += yInput * delta * 2
	global_rotation.x = clampf(global_rotation.x, -1.3, 1.3)

func rotate_camera_x(xInput : float, delta : float):
	var originalY : float = camera.global_rotation.y
	camera.global_rotation.y += xInput * delta * 2
	global_position = camera.global_position + (camera.global_basis * Vector3.FORWARD * global_position.distance_to(camera.global_position))
	camera.global_rotation.y = originalY
	global_rotation.y += xInput * delta * 2
