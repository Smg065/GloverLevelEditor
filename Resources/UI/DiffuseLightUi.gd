extends Control
class_name DiffuseLightUI

var index : int
@export var numberDisplay : Label
@export var colorPicker : ColorPickerButton
@export var thetaInput : VectorInput

func set_diffuse_info(newIndex : int, diffuseLight : Level.DiffuseLight) -> void:
	index = newIndex
	numberDisplay.text = str(index + 1)
	colorPicker.color = diffuseLight.color
	thetaInput.set_vector(diffuseLight.theta)
