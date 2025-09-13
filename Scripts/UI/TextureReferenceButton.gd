extends Button
class_name TextureReferenceButton

var textureRef : TextureReference

func build_new(newTextureRef : TextureReference):
	textureRef = newTextureRef
	text = textureRef.filename
	set("theme_override_font_sizes/font_size", 32)
	tooltip_text = textureRef.objectId
