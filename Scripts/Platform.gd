extends Node3D
class_name Platform

var modelRef : ModelReference
var platformTag : int = -1

func setup_platform(newModelRef : ModelReference, modelUpdateSignal : Signal, newPlatformTag : int = -1) -> void:
	modelRef = newModelRef
	platformTag = newPlatformTag
	set_model()
	modelUpdateSignal.connect(model_ref_updated)

func set_model():
	var modelVis = modelRef.model.instantiate()
	modelVis.name = "Model"
	var existingModel = find_child("Model")
	if existingModel != null:
		existingModel.queue_free()
	add_child(modelVis)

func model_ref_updated(incomingModelRef : ModelReference):
	if incomingModelRef.filename == modelRef.filename:
		modelRef = incomingModelRef
		set_model()
