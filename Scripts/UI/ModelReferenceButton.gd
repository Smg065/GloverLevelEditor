extends Button
class_name ModelReferenceButton

var modelRef : ModelReference

func build_new(newModelRef : ModelReference):
	modelRef = newModelRef
	text = modelRef.filename
	set("theme_override_font_sizes/font_size", 32)
	tooltip_text = modelRef.objectId
	icon = newModelRef.previewTexture
