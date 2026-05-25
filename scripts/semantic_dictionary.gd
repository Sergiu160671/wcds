## SemanticDictionary — загрузчик и провайдер словаря значений.
## Читает meanings_ru.json и предоставляет смысловые облака для слов.
extends Node

var _data: Dictionary = {}

const DICT_PATH := "res://data/meanings_ru.json"


func _ready() -> void:
	_load_dictionary()


func _load_dictionary() -> void:
	if not FileAccess.file_exists(DICT_PATH):
		push_warning("[SemanticDictionary] meanings_ru.json not found at %s" % DICT_PATH)
		return

	var file := FileAccess.open(DICT_PATH, FileAccess.READ)
	if file == null:
		push_error("[SemanticDictionary] Failed to open %s" % DICT_PATH)
		return

	var text := file.get_as_text()
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error("[SemanticDictionary] JSON parse error: %s" % json.get_error_message())
		return

	_data = json.data
	print("[SemanticDictionary] Loaded %d word entries." % _data.size())


func get_meanings(word: String) -> Array:
	var key := word.to_lower()
	if _data.has(key):
		return _data[key]
	return []


func has_word(word: String) -> bool:
	return _data.has(word.to_lower())


func word_count() -> int:
	return _data.size()