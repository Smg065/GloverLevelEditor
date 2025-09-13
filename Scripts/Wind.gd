extends MeshInstance3D
class_name Wind

var windBox : AABB
var velocity : Vector3
var turbulence : float
var active : bool
var tag : int

func _ready() -> void:
	setup_visualization()
	update_windbox_visual()

func setup_visualization():
	mesh = BoxMesh.new()
	var usedMat : ShaderMaterial = ShaderMaterial.new()
	usedMat.shader = load("res://Shaders/AABB.gdshader")
	usedMat.set_shader_parameter("albedo", Color.SKY_BLUE)
	usedMat.set_shader_parameter("texture_albedo", load("res://Textures/BoxLines.png"))
	set_surface_override_material(0, usedMat)

func update_windbox_visual():
	global_position = windBox.get_center()
	mesh.size = windBox.size
