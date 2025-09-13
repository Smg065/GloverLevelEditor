extends Resource
class_name TextureReference

#Model Refrences
var imageTexture : ImageTexture
var filename : String
var filepath : String
var objectId : String

func _init(newImageTexture : ImageTexture, newFilename : String, newFilePath : String) -> void:
	build(newImageTexture, newFilename, newFilePath)

func build(newImageTexture : ImageTexture, newFilename : String, newFilePath : String) -> void:
	imageTexture = newImageTexture
	filename = newFilename
	filepath = newFilePath
	objectId = CRCHash.get_object_id(filename, ".bmp")

static func load_texture(tryFilepath : String):
	var newImage : Image = Image.new()
	var error = newImage.load(tryFilepath)
	if error == OK:
		var newTexture : ImageTexture = ImageTexture.new()
		newTexture.set_image(newImage)
		var newFilename : String = tryFilepath.get_file()
		newFilename = newFilename.get_slice(".", 0)
		return TextureReference.new(newTexture, newFilename, tryFilepath)
	else:
		push_error("Couldn't load image!")
