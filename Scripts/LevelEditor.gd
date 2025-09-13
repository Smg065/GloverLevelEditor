extends Node
class_name LevelEditor

#UI
@export var diffuseLightList : VBoxContainer
@export var diffuseLightUiPrefab : PackedScene
@export var cameraControls : CameraControls
@export var modelLoadWindow : ButtonChoiceWindow

@export_category("Level")
@export var level : Level

@export_category("File System")
@export var openModel : FileDialog
@export var openTexture : FileDialog
@export var confirmOverwrite : ConfirmationDialog
var existingModels : Dictionary
var existingTextures : Dictionary
var overwriteInstruction : Callable = push_error.bind("Attempted to overwrite a file at an invalid time!")

signal ModelUpdated
signal TextureUpdated

func _ready() -> void:
	diffuse_lights_updated()
	modelLoadWindow.addCallable = openModel.show

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ImportModel"):
		openModel.show()
	if Input.is_action_just_pressed("ImportTexture"):
		openTexture.show()

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
		existingModels[nameEntry].build(modelReference.arrayMesh, modelReference.filename, modelReference.filepath)
		for eachChild in modelLoadWindow.get_children():
			if eachChild.modelRef.filename == modelReference.filename:
				eachChild.modelRef.build(modelReference.arrayMesh, modelReference.filename, modelReference.filepath)
				eachChild.build_new(modelReference)
				break
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
		TextureUpdated.emit(existingTextures[nameEntry])
	else:
		#Create a new texture
		var newTextureButton : TextureReferenceButton = TextureReferenceButton.new()
		#texturePathList.add_child(newTextureButton)
		newTextureButton.build_new(textureReference)
		newTextureButton.pressed.connect(set_background.bind(textureReference))
		existingTextures[nameEntry] = textureReference

func find_duplicate(lookup : Dictionary, key : String):
	if lookup.has(key):
		confirmOverwrite.dialog_text = "Overwrite \"%s\"?" % key
		confirmOverwrite.visible = true
		return true
	return false

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
	level.update_backdrop()

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
		newChild.set_diffuse_info(eachIndex, level.diffuseLights[eachIndex])

static func path_to_filename(path : String) -> String:
	return path.get_file().trim_suffix("." + path.get_extension())
