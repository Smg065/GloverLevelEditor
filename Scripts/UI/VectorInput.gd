extends HBoxContainer
class_name VectorInput

enum VectorType {VECTOR_2, VECTOR_3, VECTOR_4}
@export var vectorType : VectorType
@export var vectNames : PackedStringArray = ["X", "Y", "Z", "W"]
@export var minMax : Vector2
@export var isInt : bool

signal VectorChanged

func _ready() -> void:
	var vectorLength : int
	match vectorType:
		VectorType.VECTOR_2:
			vectorLength = 2
		VectorType.VECTOR_3:
			vectorLength = 3
		VectorType.VECTOR_4:
			vectorLength = 4
	for eachAxis in vectorLength:
		var newSpin : SpinBox = SpinBox.new()
		add_child(newSpin)
		newSpin.prefix = vectNames[eachAxis]
		newSpin.step = 0
		newSpin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		newSpin.value_changed.connect(update_vector)
		newSpin.min_value = minMax.x
		newSpin.max_value = minMax.y
		if isInt:
			newSpin.step = 1
		else:
			newSpin.step = .01

func set_vector(inVector):
	match vectorType:
		VectorType.VECTOR_2:
			get_child(0).value = inVector.x
			get_child(1).value = inVector.y
		VectorType.VECTOR_3:
			get_child(0).value = inVector.x
			get_child(1).value = inVector.y
			get_child(2).value = inVector.z
		VectorType.VECTOR_4:
			get_child(0).value = inVector.x
			get_child(1).value = inVector.y
			get_child(2).value = inVector.z
			get_child(3).value = inVector.w

func update_vector(_new_value : float):
	var outVector
	match vectorType:
		VectorType.VECTOR_2:
			outVector = Vector2(get_child(0).value, get_child(1).value)
		VectorType.VECTOR_3:
			outVector = Vector3(get_child(0).value, get_child(1).value, get_child(2).value)
		VectorType.VECTOR_4:
			outVector = Vector4(get_child(0).value, get_child(1).value, get_child(2).value, get_child(3).value)
	VectorChanged.emit(outVector)
