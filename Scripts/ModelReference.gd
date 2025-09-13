extends Resource
class_name ModelReference

#Model Refrences
var model : PackedScene
var filename : String
var filepath : String
var objectId : String
var previewTexture : SceneTexture

func _init(newModel : PackedScene, newFilename : String, newFilePath : String, newPreviewTexture : SceneTexture) -> void:
	build(newModel, newFilename, newFilePath, newPreviewTexture)

func build(newModel : PackedScene, newFilename : String, newFilePath : String, newPreviewTexture : SceneTexture):
	model = newModel
	filename = newFilename
	filepath = newFilePath
	previewTexture = newPreviewTexture
	objectId = CRCHash.get_object_id(filename, ".ndo")

static func load_model(tryFilepath : String):
	var document : GLTFDocument = GLTFDocument.new()
	var stateLoad : GLTFState = GLTFState.new()
	var error = document.append_from_file(tryFilepath, stateLoad)
	if error == OK:
		var generatedScene : Node3D = document.generate_scene(stateLoad)
		var sceneTexture : SceneTexture = SceneTexture.new()
		var packedScene : PackedScene = PackedScene.new()
		packedScene.pack(generatedScene)
		sceneTexture.scene = packedScene
		return ModelReference.new(packedScene, stateLoad.filename, tryFilepath, sceneTexture)
	else:
		push_error("Couldn't load glTF!")
