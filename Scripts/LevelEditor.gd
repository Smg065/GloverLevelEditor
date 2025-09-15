extends Node
class_name LevelEditor

#UI
@export_category("Diffuse Light UI")
@export var diffuseLightList : VBoxContainer
@export var diffuseLightUiPrefab : PackedScene

@export_category("Asset Selection UI")
@export var modelLoadWindow : ButtonChoiceWindow
@export var textureLoadWindow : ButtonChoiceWindow

@export_category("Skybox UI")
@export var skyboxButton : Button
@export var skyboxEnabledToggled : CheckBox
@export var skyboxFlipX : CheckBox
@export var skyboxFlipY : CheckBox
@export var skyboxScaleUI : VectorInput
@export var skyboxDecalPosUI : VectorInput
@export var skyboxMiscXYUI : VectorInput

@export_category("Editor Camera UI")
@export var cameraDebugLabel : Label
@export var cameraControls : CameraControls

@export_category("Level")
@export var level : Level

@export_category("File System")
@export var openModel : FileDialog
@export var openTexture : FileDialog
@export var confirmOverwrite : ConfirmationDialog
var existingModels : Dictionary
var existingTextures : Dictionary
var overwriteInstruction : Callable = push_error.bind("Attempted to overwrite a file at an invalid time!")

var nullTexture : Texture = preload("res://Sprites/Null.png")

signal ModelUpdated
signal TextureUpdated

func _ready() -> void:
	diffuse_lights_updated()
	skybox_updated()
	modelLoadWindow.addCallable = openModel.show
	textureLoadWindow.addCallable = openTexture.show
	modelLoadWindow.ConfirmSelected.connect(model_loaded)
	textureLoadWindow.ConfirmSelected.connect(set_background)
	skyboxScaleUI.VectorChanged.connect(update_backdrop_scale)
	skyboxDecalPosUI.VectorChanged.connect(update_backdrop_decal_position)
	skyboxMiscXYUI.VectorChanged.connect(update_backdrop_misc_vector)

func _process(_delta: float) -> void:
	update_camera_pos()

func skybox_updated() -> void:
	skyboxEnabledToggled.button_pressed = level.backdrop.enable
	skyboxFlipX.button_pressed = level.backdrop.flipX
	skyboxFlipY.button_pressed = level.backdrop.flipY
	if level.backdrop.texture.imageTexture != null:
		skyboxButton.icon = level.backdrop.texture.imageTexture
	else:
		skyboxButton.icon = nullTexture
	skyboxScaleUI.set_vector(level.backdrop.scale)
	skyboxDecalPosUI.set_vector(level.backdrop.decalPos)
	skyboxMiscXYUI.set_vector(Vector2(level.backdrop.scrollSpeedX, level.backdrop.offsetY))

func model_file_selected(path : String):
	var nameEntry : String = path_to_filename(path)
	if find_duplicate(existingModels, nameEntry):
		overwriteInstruction = new_model_refrence.bind(path)
		return
	new_model_refrence(path)

func image_file_selected(path : String):
	var nameEntry : String = path_to_filename(path)
	if find_duplicate(existingTextures, nameEntry):
		overwriteInstruction = new_texture_refrence.bind(path)
		return
	new_texture_refrence(path)

func new_model_refrence(path : String) -> void:
	var nameEntry : String = path_to_filename(path)
	var modelReference : ModelReference = ModelReference.load_model(path)
	#Overwrite an existing model
	if existingModels.has(nameEntry):
		existingModels[nameEntry] = modelReference
		modelLoadWindow.update_button(modelReference.filename, modelReference.previewTexture, modelReference)
		ModelUpdated.emit(existingModels[nameEntry])
	else:
		#Create a new model
		modelLoadWindow.add_button(modelReference.filename, modelReference.previewTexture, modelReference)
		existingModels[nameEntry] = modelReference

func new_texture_refrence(path : String) -> void:
	var nameEntry : String = path_to_filename(path)
	var textureReference : TextureReference = TextureReference.load_texture(path)
	#Overwrite an existing texture
	if existingTextures.has(nameEntry):
		existingTextures[nameEntry].build(textureReference.imageTexture, textureReference.filename, textureReference.filepath)
		textureLoadWindow.update_button(textureReference.filename, textureReference.imageTexture, textureReference)
		TextureUpdated.emit(existingTextures[nameEntry])
	else:
		#Create a new texture
		textureLoadWindow.add_button(textureReference.filename, textureReference.imageTexture, textureReference)
		existingTextures[nameEntry] = textureReference

func find_duplicate(lookup : Dictionary, key : String):
	if lookup.has(key):
		confirmOverwrite.dialog_text = "Overwrite \"%s\"?" % key
		confirmOverwrite.visible = true
		return true
	return false

func spawn_platform_pressed():
	modelLoadWindow.get_parent().show()

func spawn_land_actor_pressed():
	modelLoadWindow.get_parent().show()

func model_loaded(modelReference : ModelReference):
	new_platform(modelReference)

func new_platform(modelReference : ModelReference):
	var loadPlatform : Platform = Platform.new()
	loadPlatform.setup_platform(modelReference, ModelUpdated)
	add_child(loadPlatform)
	loadPlatform.global_position = cameraControls.global_position + (cameraControls.global_basis * Vector3.FORWARD * 4)

func new_land_actor(modelReference : ModelReference):
	var loadPlatform : LandActor = LandActor.new()
	loadPlatform.setup_land_actor(modelReference)
	add_child(loadPlatform)

func set_background(textureReference : TextureReference):
	level.backdrop.texture = textureReference
	skyboxButton.icon = textureReference.imageTexture
	level.update_backdrop()

func update_diffuse_light_count():
	level.diffuseLights.resize(diffuseLightList.get_children().size())
	level.update_diffuse_light_count()
	update_diffuse_lights()

func update_diffuse_lights(_null = null):
	var lightUis : Array[DiffuseLightUI]
	lightUis.append_array(diffuseLightList.get_children())
	for lightIndex in lightUis.size():
		var eachLightUi : DiffuseLightUI = lightUis[lightIndex]
		var diffuseInfo : Level.DiffuseLight = eachLightUi.get_diffuse_info()
		level.diffuseLights[lightIndex] = diffuseInfo
	level.update_diffuse_light_info()

func confirm_overwrite():
	overwriteInstruction.call()
	overwriteInstruction = push_error.bind("Attempted to overwrite a file at an invalid time!")

func cancel_overwrite():
	overwriteInstruction = push_error.bind("Attempted to overwrite a file at an invalid time!")

func set_skybox_color(newColor : Color):
	level.backdropClearColor.color = newColor

func set_ambient_light_color(newColor : Color):
	level.ambientLight = newColor
	level.update_ambient_light()

func set_fog_color(newColor : Color) -> void:
	level.fogConfiguration.color = newColor
	level.update_fog_visuals()
	set_skybox_color(newColor)

func set_fog_near(newNear : float) -> void:
	level.fogConfiguration.near = newNear
	level.update_fog_visuals()

func set_fog_distance(newDistance : float) -> void:
	level.fogConfiguration.distance = newDistance
	level.update_fog_visuals()

func set_fog_enabled(toggled_on: bool) -> void:
	level.fogConfiguration.fogEnabled = toggled_on
	level.update_fog_visuals()

func diffuse_lights_updated():
	for eachChild in diffuseLightList.get_children():
		eachChild.queue_free()
	for eachIndex in level.diffuseLights.size():
		var newChild = diffuseLightUiPrefab.instantiate()
		diffuseLightList.add_child(newChild)
		newChild.set_diffuse_info(eachIndex, level.diffuseLights[eachIndex], self)

static func path_to_filename(path : String) -> String:
	return path.get_file().trim_suffix("." + path.get_extension())

func skybox_flip_x(toggled_on: bool) -> void:
	level.backdrop.flipX = toggled_on
	level.update_backdrop()

func skybox_flip_y(toggled_on: bool) -> void:
	level.backdrop.flipY = toggled_on
	level.update_backdrop()

func toggle_backdrop_enabled(toggled_on: bool) -> void:
	level.backdrop.enable = toggled_on
	level.update_backdrop()

func update_backdrop_scale(newScale : Vector2) -> void:
	level.backdrop.scale = newScale
	level.update_backdrop()

func update_backdrop_decal_position(dealPos : Vector2) -> void:
	level.backdrop.decalPos = dealPos
	level.update_backdrop()

func update_backdrop_misc_vector(miscVector : Vector2) -> void:
	level.backdrop.scrollSpeedX = roundi(miscVector.x)
	level.backdrop.offsetY = roundi(miscVector.y)
	level.update_backdrop()

func update_camera_pos():
	var cameraPos : Vector3 = cameraControls.camera.global_position
	var cameraRot : Vector3 = cameraControls.camera.global_rotation
	var outString : String = "X:     %8.3f\n" % cameraPos.x
	outString += "Y:     %8.3f\n" % cameraPos.y
	outString += "Z:     %8.3f\n" % cameraPos.z
	outString += "Pitch: %8.3f\n" % cameraRot.x
	outString += "Yaw:   %8.3f" % cameraRot.y
	cameraDebugLabel.text = outString
