extends WorldEnvironment
class_name Level

@export var backdropTexture : TextureRect
@export var backdropClearColor : ColorRect
@export var diffuseLightsContainer : Node3D

class FogConfiguration:
	var fogEnabled : bool
	var color : Color
	var near : float
	var distance : float

class DiffuseLight:
	var color : Color
	var theta : Vector2
	func _init(r : int, g: int, b: int, x : float, y : float) -> void:
		color = Color8(r, g, b)
		theta = Vector2(x, y)

class Backdrop:
	var texture : TextureReference
	var decalPos : Vector2
	var sortKey : int
	var offset : Vector2
	var scale : Vector2 = Vector2(4096, 4096)
	var scrollSpeed : Vector2
	var flipX : bool
	var flipY : bool
	var unused : int = 0
	var decalParentIdx : int = 0

var ambientLight : Color = Color.WHITE
var diffuseLights : Array[DiffuseLight]
var backdrop : Backdrop
var fogConfiguration : FogConfiguration

func _ready() -> void:
	backdrop = Backdrop.new()
	environment.fog_mode = Environment.FOG_MODE_DEPTH
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	fogConfiguration = FogConfiguration.new()
	#Default lights
	diffuseLights.clear()
	diffuseLights.append(DiffuseLight.new(160, 160, 220, 0.0, 3.7))
	diffuseLights.append(DiffuseLight.new(160, 160, 160, 4.28, 0.0))
	update_ambient_light()
	update_diffuse_lights()
	update_fog_visuals()

func update_ambient_light():
	environment.ambient_light_color = ambientLight

func update_diffuse_lights():
	for eachChild in diffuseLightsContainer.get_children():
		eachChild.queue_free()
	#for eachLight in diffuseLights:
	#	var newLight : DirectionalLight3D = DirectionalLight3D.new()
	#	newLight.light_color = eachLight.color
	#	diffuseLightsContainer.add_child(newLight)

func update_fog_visuals():
	environment.fog_enabled = fogConfiguration.fogEnabled
	if fogConfiguration.fogEnabled:
		environment.fog_light_color = fogConfiguration.color
		environment.fog_depth_begin = fogConfiguration.near
		environment.fog_depth_end = fogConfiguration.near + fogConfiguration.distance

func update_backdrop():
	backdropTexture.texture = backdrop.texture.imageTexture
	backdropTexture.flip_h = backdrop.flipX
	backdropTexture.flip_v = backdrop.flipY
	backdropTexture.scale = backdrop.scale / 1024
