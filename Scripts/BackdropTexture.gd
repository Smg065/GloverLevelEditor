extends TextureRect

var level : Level
var cam : CameraControls

func _ready() -> void:
	level = get_parent().get_parent()
	cam = get_tree().get_first_node_in_group("EditCam")

func _process(_delta: float) -> void:
	if !visible:
		return
	var pitch : float = cam.camera.global_rotation.x
	var yaw : float = cam.camera.global_rotation.y
	var backdropWidth : float = level.backdrop.texture.imageTexture.get_size().x
	var xCord : float = -(yaw + 0.5) * level.backdrop.scrollSpeedX * backdropWidth
	var yCord : float = min(((-sin(pitch*2*PI)*500.0 + level.backdrop.offsetY)/2.0) + (136.0/(level.backdrop.scale.y/1024.0)), 0)
	print("X: " + str(xCord) + "Y: " + str(yCord))
