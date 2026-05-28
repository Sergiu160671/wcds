## TestRunner — простая система тестирования основных компонентов.
extends Node

var test_results: Dictionary = {
	"passed": 0,
	"failed": 0,
	"tests": []
}


func _ready() -> void:
	print("\n=== SOS Semantic Cloud MVP — Test Suite ===\n")
	
	# Запуск тестов
	test_dictionary_loading()
	test_word_node_creation()
	test_meaning_cloud_drift()
	test_context_field()
	test_simulation_flow()
	
	# Вывод результатов
	_print_results()


func _assert(condition: bool, test_name: String, message: String = "") -> void:
	var status := "✓ PASS" if condition else "✗ FAIL"
	print("  %s: %s %s" % [status, test_name, message])
	
	if condition:
		test_results["passed"] += 1
	else:
		test_results["failed"] += 1
	
	test_results["tests"].append({
		"name": test_name,
		"passed": condition,
		"message": message
	})


func test_dictionary_loading() -> void:
	print("[Test] Dictionary Loading")
	
	_assert(SemanticDictionary != null, "SemanticDictionary singleton loaded")
	_assert(SemanticDictionary.word_count() > 0, "Dictionary has entries", "(count: %d)" % SemanticDictionary.word_count())
	_assert(SemanticDictionary.has_word("свет"), "Dictionary has key word 'свет'")
	
	var meanings = SemanticDictionary.get_meanings("свет")
	_assert(meanings.size() > 0, "Word 'свет' has meanings", "(count: %d)" % meanings.size())
	print()


func test_word_node_creation() -> void:
	print("[Test] WordNode Creation")
	
	var pos := Vector2(100, 100)
	var word := WordNode.new("тест", pos)
	
	_assert(word != null, "WordNode created")
	_assert(word.text == "тест", "WordNode text correct")
	_assert(word.position == pos, "WordNode position correct")
	_assert(word.meaning_clusters.size() == 0, "WordNode starts with empty clusters")
	
	word.add_cloud("облако1", 0.5, 0.3, pos, "neutral")
	_assert(word.meaning_clusters.size() == 1, "Cloud added to WordNode", "(clusters: %d)" % word.meaning_clusters.size())
	print()


func test_meaning_cloud_drift() -> void:
	print("[Test] MeaningCloud Drift")
	
	var cloud := MeaningCloud.new("тест", 0.5, 0.5, Vector2(0, 0), "neutral")
	var initial_pos := cloud.position
	
	_assert(cloud != null, "MeaningCloud created")
	_assert(cloud.weight == 0.5, "MeaningCloud weight set")
	_assert(cloud.entropy == 0.5, "MeaningCloud entropy set")
	
	# Применение силы
	cloud.apply_force(Vector2(1, 0))
	var new_pos := cloud.position
	_assert(new_pos != initial_pos, "Cloud drifted after force", "(from %s to %s)" % [initial_pos, new_pos])
	
	var distance := cloud.drift_distance()
	_assert(distance > 0, "Drift distance calculated", "(%.2f)" % distance)
	print()


func test_context_field() -> void:
	print("[Test] ContextField")
	
	_assert(ContextField != null, "ContextField singleton loaded")
	
	# Проверка начального состояния
	var initial_direction := ContextField.direction
	var initial_strength := ContextField.strength
	
	# Настройка поля
	ContextField.configure(Vector2.DOWN, 0.7, ["тест"])
	
	_assert(ContextField.direction == Vector2.DOWN, "ContextField direction updated")
	_assert(ContextField.strength == 0.7, "ContextField strength updated")
	_assert("тест" in ContextField.bias_keywords, "Keyword added to bias")
	print()


func test_simulation_flow() -> void:
	print("[Test] Simulation Flow")
	
	_assert(Simulation != null, "Simulation singleton loaded")
	_assert(Simulation.words.size() == 0, "Simulation starts empty")
	
	# Добавление слова
	var word := Simulation.add_word("свет")
	_assert(word != null, "Word added to simulation")
	_assert(Simulation.words.size() == 1, "Word count increased", "(count: %d)" % Simulation.words.size())
	_assert(word.meaning_clusters.size() > 0, "Word has clouds", "(count: %d)" % word.meaning_clusters.size())
	
	# Получение слова
	var retrieved := Simulation.get_word("свет")
	_assert(retrieved == word, "Word retrieved from simulation")
	
	# Метрики
	var metrics := Simulation.system_metrics()
	_assert(metrics.size() > 0, "Metrics available", "(keys: %s)" % metrics.keys())
	_assert(metrics["word_count"] == 1, "Metrics word count correct")
	_assert(metrics["cloud_count"] > 0, "Metrics cloud count correct")
	
	# Шаг симуляции
	Simulation.step(ContextField)
	_assert(Simulation.frame_count > 0, "Simulation frame advanced")
	
	# Удаление слова
	Simulation.remove_word("свет")
	_assert(Simulation.words.size() == 0, "Word removed", "(remaining: %d)" % Simulation.words.size())
	print()


func _print_results() -> void:
	print("\n=== Test Results ===")
	print("  Passed: %d ✓" % test_results["passed"])
	print("  Failed: %d ✗" % test_results["failed"])
	print("  Total:  %d" % (test_results["passed"] + test_results["failed"]))
	print()
	
	if test_results["failed"] == 0:
		print("🎉 All tests passed!")
	else:
		print("⚠️  Some tests failed. Review above.")
	
	print("\n=== Starting Simulation ===\n")
