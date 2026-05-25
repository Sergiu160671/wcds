extends Control

@onready var word_input: LineEdit = $Panel/VBoxContainer/WordInput
@onready var add_button: Button = $Panel/VBoxContainer/AddButton
@onready var word_list: ItemList = $Panel/VBoxContainer/WordList
@onready var remove_button: Button = $Panel/VBoxContainer/RemoveButton
@onready var context_input: LineEdit = $Panel/VBoxContainer/ContextInput
@onready var apply_context_button: Button = $Panel/VBoxContainer/ApplyContextButton
@onready var metrics_label: Label = $Panel/VBoxContainer/MetricsLabel

func _ready() -> void:
	add_button.pressed.connect(_on_add_pressed)
	remove_button.pressed.connect(_on_remove_pressed)
	apply_context_button.pressed.connect(_on_apply_context_pressed)

func _on_add_pressed() -> void:
	var text := word_input.text.strip_edges()
	if text != "":
		Simulation.add_word(text)
		_refresh_list()
		word_input.clear()

func _on_remove_pressed() -> void:
	var selected := word_list.get_selected_items()
	if selected.size() > 0:
		var text := word_list.get_item_text(selected[0])
		Simulation.remove_word(text)
		_refresh_list()

func _on_apply_context_pressed() -> void:
	var keywords_raw := context_input.text.split(",", false)
	var trimmed: Array[String] = []
	for k in keywords_raw:
		trimmed.append(k.strip_edges())
	ContextField.configure(Vector2.RIGHT, 0.5, trimmed)

func _refresh_list() -> void:
	word_list.clear()
	for word in Simulation.words:
		word_list.add_item(word.text)

func _process(_delta: float) -> void:
	var metrics := Simulation.system_metrics()
	if not metrics.is_empty():
		metrics_label.text = "Слов: %d, Облаков: %d, Энтропия: %.2f" % [
			metrics["word_count"],
			metrics["cloud_count"],
			metrics["system_entropy"]
		]
