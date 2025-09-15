extends Control
class_name DiffuseLightUI

var index : int
@export var numberDisplay : Label
@export var colorPicker : ColorPickerButton
@export var thetaInput : VectorInput
var theta : Vector2

signal theta_updated

func _ready() -> void:
	thetaInput.VectorChanged.connect(set_theta)

func set_diffuse_info(newIndex : int, diffuseLight : Level.DiffuseLight, levelEditor : LevelEditor) -> void:
	index = newIndex
	numberDisplay.text = str(index + 1)
	colorPicker.color = diffuseLight.color
	thetaInput.set_vector(diffuseLight.theta)
	colorPicker.color_changed.connect(levelEditor.update_diffuse_lights)
	theta_updated.connect(levelEditor.update_diffuse_lights)

func set_theta(newTheta : Vector2):
	theta = newTheta
	theta_updated.emit()

func get_diffuse_info() -> Level.DiffuseLight:
	return Level.DiffuseLight.new(colorPicker.color.r8, colorPicker.color.g8, colorPicker.color.b8, theta.x, theta.y)
