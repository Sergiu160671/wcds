## SaveManager — управление сохранением/загрузкой состояний.
## Автозагружаемый синглтон для сохранения снимков симуляции.
extends Node

const SAVE_DIR := "user://sos_saves/"
const STATE_PREFIX := "simulation_"

var current_save: String = ""


func _ready() -> void:
	_ensure_save_directory()
	print("[SaveManager] Ready. Save directory: %s" % SAVE_DIR)


func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		var dir = DirAccess.open("user://")
		if dir:
			dir.make_dir("sos_saves")
		else:
			push_warning("[SaveManager] Could not create save directory")


func save_state(name: String = "") -> bool:
	"""Сохраняет текущее состояние симуляции."""
	var timestamp := Time.get_datetime_string_from_system().split("T")[0] + "_" + str(Time.get_ticks_msec() % 100000)
	var filename := STATE_PREFIX + (name if name else timestamp) + ".json"
	var filepath := SAVE_DIR + filename
	
	var state := Simulation.export_state()
	var json_str := JSON.stringify(state)
	
	var file := FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		push_error("[SaveManager] Failed to open file: %s" % filepath)
		return false
	
	file.store_string(json_str)
	current_save = filename
	print("[SaveManager] State saved: %s" % filename)
	return true


func load_state(filename: String) -> bool:
	"""Загружает сохранённое состояние."""
	var filepath := SAVE_DIR + filename
	
	if not FileAccess.file_exists(filepath):
		push_error("[SaveManager] File not found: %s" % filepath)
		return false
	
	var file := FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		push_error("[SaveManager] Failed to open file: %s" % filepath)
		return false
	
	var json_str := file.get_as_text()
	var json := JSON.new()
	if json.parse(json_str) != OK:
		push_error("[SaveManager] JSON parse error: %s" % json.get_error_message())
		return false
	
	var state = json.data
	_restore_state(state)
	current_save = filename
	print("[SaveManager] State loaded: %s" % filename)
	return true


func list_saves() -> Array:
	"""Возвращает список всех сохранённых состояний."""
	var saves: Array = []
	var dir := DirAccess.open(SAVE_DIR)
	
	if dir:
		dir.list_dir_begin()
		var filename := dir.get_next()
		while filename != "":
			if filename.begins_with(STATE_PREFIX) and filename.ends_with(".json"):
				saves.append(filename)
			filename = dir.get_next()
	
	return saves


func _restore_state(state: Dictionary) -> void:
	"""Восстанавливает состояние из словаря (может быть расширено позже)."""
	print("[SaveManager] Restoring state...")
	print("  Frame: %d" % state.get("frame", 0))
	print("  Words: %d" % (state.get("metrics", {}).get("word_count", 0)))
	print("  Precipitation events: %d" % state.get("precipitation_log", []).size())


func export_json(filename: String = "export") -> bool:
	"""Экспортирует текущее состояние в JSON для анализа."""
	var filepath := SAVE_DIR + filename + ".json"
	var state := Simulation.export_state()
	var json_str := JSON.stringify(state)
	
	var file := FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		push_error("[SaveManager] Failed to export: %s" % filepath)
		return false
	
	file.store_string(json_str)
	print("[SaveManager] Exported to: %s" % filepath)
	return true
