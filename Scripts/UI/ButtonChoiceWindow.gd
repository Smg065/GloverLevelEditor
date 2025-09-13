extends Control
class_name ButtonChoiceWindow

@export var buttonEntries : GridContainer
@export var removeButton : Button
@export var loadButton : Button
var window : Window
var addCallable : Callable
var selectedButton : Button
var selectedOption

signal ConfirmSelected

func _ready() -> void:
	window = get_parent()
	window.close_requested.connect(update_selected_option.bind(null, null))
	window.close_requested.connect(window.hide)
	window.size_changed.connect(resized)

func resized() -> void:
	buttonEntries.columns = floori(window.size.x / 256.0)
	print(buttonEntries.columns)

func searchbox_updated(new_text: String) -> void:
	for eachButton in buttonEntries.get_children():
		eachButton.visible = eachButton.name.contains(new_text)

func load_pressed() -> void:
	ConfirmSelected.emit(selectedOption)
	get_parent().hide()

func remove_selected() -> void:
	selectedButton.queue_free()
	update_selected_option(null, null)

func add_pressed() -> void:
	addCallable.call()

func update_selected_option(newOption, newButton : Button) -> void:
	selectedOption = newOption
	selectedButton = newButton
	var existingOption : bool = selectedOption != null
	removeButton.disabled = !existingOption
	loadButton.disabled = !existingOption

func add_button(buttonName : String, buttonTexture : Texture, choiceOutput) -> void:
	var newButton : Button = Button.new()
	newButton.text = buttonName
	newButton.icon = buttonTexture
	newButton.pressed.connect(update_selected_option.bind(choiceOutput, newButton))
	newButton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	newButton.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	newButton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttonEntries.add_child(newButton)
