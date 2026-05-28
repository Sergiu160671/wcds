extends Control
## UIController — управление интерфейсом симуляции.
## Связывает UI элементы с Simulation и ContextField.

@onready var vbox: VBoxContainer = $Panel/ScrollContainer/MarginContainer/VBoxContainer
@onready var word_input: LineEdit = vbox.get_node("WordInput") as LineEdit
@onready var add_button: Button = vbox.get_node("AddButton") as Button
@onready var word_list: ItemList = vbox.get_node("WordList") as ItemList
@onready var remove_button: Button = vbox.get_node("RemoveButton") as Button
@onready var context_input: LineEdit = vbox.get_node("ContextInput") as LineEdit
@onready var apply_context_button: Button = vbox.get_node("ApplyContextButton") as Button
@onready var metrics_label: Label = vbox.get_node("MetricsLabel") as Label
@onready var dominant_label: Label = vbox.get_node("DominantLabel") as Label

var update_interval: float = 0.1
var time_elapsed: float = 0.0

func _ready() -> void:
	print("[UIController] Initializing UI connections...")
	add_button.pressed.connect(_on_add_pressed)
	remove_button.pressed.connect(_on_remove_pressed)
	apply_context_button.pressed.connect(_on_apply_context_pressed)
	word_input.text_submitted.connect(_on_word_submitted)
	_refresh_list()
	print("[UIController] UI ready.")

func _on_word_submitted(new_text: String) -> void:
	_on_add_pressed()

func _on_add_pressed() -> void:
	var text := word_input.text.strip_edges()
	if text == "":
		print("[UIController] Empty word input ignored.")
		return
	
	if not SemanticDictionary.has_word(text):
		print("[UIController] Warning: word '%s' not in dictionary. Creating with neutral cloud." % text)
	
	var word := Simulation.add_word(text)
	print("[UIController] Added word: %s (clouds: %d)" % [text, word.meaning_clusters.size()])
	_refresh_list()
	word_input.clear()

func _on_remove_pressed() -> void:
	var selected := word_list.get_selected_items()
	if selected.size() == 0:
		print("[UIController] No word selected for removal.")
		return
	
	var text := word_list.get_item_text(selected[0])
	Simulation.remove_word(text)
	print("[UIController] Removed word: %s" % text)
	_refresh_list()

func _on_apply_context_pressed() -> void:
	var keywords_raw := context_input.text.split(",", false)
	var trimmed: Array[String] = []
	for k in keywords_raw:
		trimmed.append(k.strip_edges().to_lower())
	
	if trimmed.is_empty() or (trimmed.size() == 1 and trimmed[0] == ""):
		print("[UIController] Clearing context.")
		ContextField.configure(Vector2.RIGHT, 0.0, [])
		return
	
	ContextField.configure(Vector2.RIGHT, 0.7, trimmed)
	print("[UIController] Context set: %s" % trimmed)

func _refresh_list() -> void:
	word_list.clear()
	for word in Simulation.words:
		word_list.add_item(word.text)

func _update_metrics_display() -> void:
	var metrics := Simulation.system_metrics()
	if metrics.is_empty():
		metrics_label.text = "Метрики: [нет слов]"
		dominant_label.text = "Доминанта: --"
		return
	
	metrics_label.text = "📊 Слов: %d | Облаков: %d | Энтропия: %.2f" % [
		metrics["word_count"],
		metrics["cloud_count"],
		metrics["system_entropy"]
	]
	
	# Показать доминирующие смыслы
	var dominant_text := "Доминанты:\n"
	for word in Simulation.words:
		var dom := word.dominant_cloud()
		if dom:
			dominant_text += "  %s → %s (%.0f%%)\n" % [
				word.text,
				dom.label,
				dom.weight * 100.0
			]
	dominant_label.text = dominant_text

func _process(_delta: float) -> void:
	time_elapsed += _delta
	if time_elapsed >= update_interval:
		_update_metrics_display()
		time_elapsed = 0.0
